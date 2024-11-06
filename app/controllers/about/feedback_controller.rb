# frozen_string_literal: true

module About
  class FeedbackController < ApplicationController
    before_action :skip_authorization

    def index
      @feedback = Feedback.new
    end

    def create
      @feedback = Feedback.new feedback_params
      if @feedback.valid?
        submit_feedback
        redirect_to your_nsm_claims_path, notice: I18n.t('feedback.submitted.success')
      else
        render 'index'
      end
    end

    private

    def submit_feedback
      FeedbackMailer
        .notify(**feedback_params.to_h
                    .symbolize_keys, application_env: application_environment)
        .deliver_later!
    end

    def feedback_params
      params.require(:feedback).permit(:user_feedback, :user_email, :user_rating)
    end

    def application_environment
      ENV.fetch('ENV', Rails.env).to_s
    end
  end
end
