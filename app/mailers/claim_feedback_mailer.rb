# frozen_string_literal: true

class ClaimFeedbackMailer < GovukNotifyRails::Mailer
  def notify(feedback_message)
    set_template(feedback_message.template)
    set_personalisation(**feedback_message.contents)
    mail(to: feedback_message.recipient)
  end
end
