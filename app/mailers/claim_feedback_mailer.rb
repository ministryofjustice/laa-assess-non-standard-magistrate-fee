# frozen_string_literal: true

class ClaimFeedbackMailer < GovukNotifyRails::Mailer
  def notify(claim)
    feedback_template = feedback_message(claim)
    set_template(feedback_template.template)
    set_personalisation(**feedback_template.contents)
    mail(to: feedback_template.recipient)
  end

  private

  def feedback_message(claim)
    case claim.state
    when 'granted'
      FeedbackMessages::GrantedFeedback.new(claim)
    when 'part_grant'
      FeedbackMessages::PartGrantedFeedback.new(claim)
    when 'rejected'
      FeedbackMessages::RejectedFeedback.new(claim)
    when 'provider_requested'
      FeedbackMessages::ProviderRequestFeedback.new(claim)
    else
      FeedbackMessages::FurtherInformationRequestFeedback.new(claim)
    end
  end
end
