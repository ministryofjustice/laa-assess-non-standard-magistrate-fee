module Nsm
  module V1
    class EqualityDetails < BaseViewModel
      attribute :answer_equality, :translated, scope: 'nsm.answer_equality'
      attribute :ethnic_group, :translated, scope: 'nsm.ethnic_group'
      attribute :gender, :translated, scope: 'nsm.gender'
      attribute :disability, :translated, scope: 'nsm.disability'

      def key
        'equality_details'
      end

      def title
        I18n.t(".nsm.claim_details.#{key}.title")
      end

      def data
        [
          {
            title: I18n.t(".nsm.claim_details.#{key}.questions"),
            value: answer_equality
          },
          *equality_answers
        ]
      end

      def equality_answers
        return [] unless answer_equality.value == 'yes'

        [
          {
            title: I18n.t(".nsm.claim_details.#{key}.ethnic_group"),
            value: ethnic_group
          },
          {
            title: I18n.t(".nsm.claim_details.#{key}.identification"),
            value: gender
          },
          {
            title: I18n.t(".nsm.claim_details.#{key}.disability"),
            value: disability
          }
        ]
      end

      def rows
        { title:, data: }
      end
    end
  end
end
