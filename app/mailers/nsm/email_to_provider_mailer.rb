# frozen_string_literal: true

module Nsm
  class EmailToProviderMailer < NotifyMailer
    def notify(submission)
      message = instantiate_message(submission)
      set_template(message.template)
      set_personalisation(**message.contents)
      mail(to: message.recipient)
    end

    private

    def instantiate_message(submission)
      case submission.state
      when 'granted'
        Messages::Granted.new(submission)
      when 'part_grant'
        Messages::PartGranted.new(submission)
      when 'rejected'
        Messages::Rejected.new(submission)
      else
        Messages::FurtherInformationRequest.new(submission)
      end
    end
  end
end
