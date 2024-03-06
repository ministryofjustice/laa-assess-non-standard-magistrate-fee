module PriorAuthority
  module V1
    class Decision < BaseViewModel
      attribute :laa_reference, :string
      attribute :submission

      delegate :state, to: :submission

      def comments
        submission.latest_decision_event.details['comment']
      end
    end
  end
end
