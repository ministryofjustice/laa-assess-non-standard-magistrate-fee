module PriorAuthority
  module V1
    class TableRow < BaseViewModel
      include ActionView::Helpers::TagHelper

      attribute :laa_reference, :string
      attribute :firm_name
      attribute :client_name
      attribute :submission

      delegate :id, to: :submission

      def date_created_str
        submission.created_at.to_fs(:stamp)
      end

      def date_assessed_str
        submission.updated_at.to_fs(:stamp)
      end

      def caseworker
        submission.assignments.first&.display_name || I18n.t('prior_authority.applications.not_assigned')
      end

      def status
        tag.span(class: "govuk-tag govuk-tag--#{tag_colour}") do
          I18n.t("prior_authority.applications.statuses.#{augmented_state}")
        end
      end

      def augmented_state
        return 'in_progress' if submission.state == 'submitted' && submission.assignments.any?

        submission.state
      end

      private

      def tag_colour
        {
          'submitted' => 'grey',
          'in_progress' => 'purple',
          'provider_updated' => 'grey',
          'sent_back' => 'yellow',
          'part_grant' => 'blue',
          'granted' => 'green',
          'rejected' => 'red'
        }.fetch(augmented_state)
      end
    end
  end
end
