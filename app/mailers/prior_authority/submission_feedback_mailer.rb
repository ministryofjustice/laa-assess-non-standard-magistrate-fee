# frozen_string_literal: true

module PriorAuthority
  class SubmissionFeedbackMailer < GovukNotifyRails::Mailer
    class InvalidState < StandardError; end

    def notify(submission)
      feedback_template = feedback_message(submission)
      set_template(feedback_template.template)
      set_personalisation(**feedback_template.contents)
      mail(to: feedback_template.recipient)
    end

    private

    def feedback_message(submission)
      case submission.state
      when 'granted'
        FeedbackMessages::GrantedFeedback.new(submission)
      when 'part_grant'
        FeedbackMessages::PartGrantedFeedback.new(submission)
      when 'rejected'
        FeedbackMessages::RejectedFeedback.new(submission)
      when 'sent_back'
        FeedbackMessages::FurtherInformationRequestFeedback.new(submission)
      else
        raise_message_for(submission)
      end
    end

    def raise_message_for(submission)
      msg = "submission with id '#{submission.id}' " \
            "has unhandlable state '#{submission.state}'"

      Sentry.capture_message(msg)

      raise InvalidState, msg
    end
  end
end
