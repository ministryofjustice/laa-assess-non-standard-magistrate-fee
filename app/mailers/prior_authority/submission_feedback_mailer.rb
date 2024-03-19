# frozen_string_literal: true

module PriorAuthority
  class SubmissionFeedbackMailer < GovukNotifyRails::Mailer
    class InvalidState < StandardError; end

    FEEDBACK_MESSAGE_KLASSES = {
      PriorAuthorityApplication::GRANTED => FeedbackMessages::GrantedFeedback,
      PriorAuthorityApplication::PART_GRANT => FeedbackMessages::PartGrantedFeedback,
      PriorAuthorityApplication::REJECTED => FeedbackMessages::RejectedFeedback,
      PriorAuthorityApplication::SENT_BACK => FeedbackMessages::FurtherInformationRequestFeedback,
    }.freeze

    def notify(submission)
      feedback_template = feedback_message(submission)
      set_template(feedback_template.template)
      set_personalisation(**feedback_template.contents)
      mail(to: feedback_template.recipient)
    end

    private

    def feedback_message(submission)
      klass = FEEDBACK_MESSAGE_KLASSES[submission.state]
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
