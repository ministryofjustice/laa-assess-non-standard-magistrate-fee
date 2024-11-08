# frozen_string_literal: true

module PriorAuthority
  class EmailToProviderMailer < NotifyMailer
    class InvalidState < StandardError; end

    MESSAGE_KLASSES = {
      PriorAuthorityApplication::GRANTED => Messages::Granted,
      PriorAuthorityApplication::AUTO_GRANT => Messages::Granted,
      PriorAuthorityApplication::PART_GRANT => Messages::PartGranted,
      PriorAuthorityApplication::REJECTED => Messages::Rejected,
      PriorAuthorityApplication::SENT_BACK => Messages::FurtherInformationRequest,
    }.freeze

    def notify(submission)
      message = instantiate_message(submission)
      set_template(message.template)
      set_personalisation(**message.contents)
      mail(to: message.recipient)
    end

    private

    def instantiate_message(submission)
      klass = MESSAGE_KLASSES[submission.state]
      klass ? klass.new(submission) : raise_message_for(submission)
    end

    def raise_message_for(submission)
      msg = "submission with id '#{submission.id}' " \
            "has unhandlable state '#{submission.state}'"

      Sentry.capture_message(msg)

      raise InvalidState, msg
    end
  end
end
