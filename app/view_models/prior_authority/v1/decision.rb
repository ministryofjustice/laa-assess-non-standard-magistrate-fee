module PriorAuthority
  module V1
    class Decision < BaseViewModel
      attribute :laa_reference, :string
      attribute :submission

      delegate :state, to: :submission

      def comments
        submission.data['assessment_comment']
      end
    end
  end
end
