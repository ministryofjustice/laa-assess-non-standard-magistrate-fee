# frozen_string_literal: true

module PriorAuthority
  module FeedbackMessages
    class FurtherInformationRequestFeedback < FeedbackBase
      def template
        'c8abf9ee-5cfe-44ab-9253-72111b7a35ba'
      end

      def contents
        {
          laa_case_reference: case_reference,
          ufn: ufn,
          defendant_name: defendant_name,
          application_total: application_total,
          date_to_respond_by: Rails.configuration.x.rfi.resubmission_window.from_now.to_fs(:stamp),
          caseworker_information_requested: comments,
          date: DateTime.now.to_fs(:stamp),
        }
      end

      protected

      def comments
        comments = []

        if further_information_explanation.present?
          comments << "## #{I18n.t('prior_authority.send_backs.show.further_information')}"
          comments << further_information_explanation
        end

        if incorrect_information_explanation.present?
          comments << "## #{I18n.t('prior_authority.send_backs.show.incorrect_information')}"
          comments << incorrect_information_explanation
        end

        comments.compact_blank.join("\n\n")
      end

      def incorrect_information_explanation
        @submission.data['incorrect_information_explanation']
      end

      def further_information_explanation
        @submission.data['further_information_explanation']
      end
    end
  end
end
