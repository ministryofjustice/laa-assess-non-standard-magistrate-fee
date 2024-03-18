module PriorAuthority
  module V1
    class SendBack < BaseViewModel
      attribute :laa_reference, :string
      attribute :updates_needed, array: true
      attribute :further_information_explanation, :string
      attribute :incorrect_information_explanation, :string
      attribute :submission

      delegate :state, to: :submission

      def further_information_requested?
        updates_needed.include?(SendBackForm::FURTHER_INFORMATION)
      end

      def corrections_requested?
        updates_needed.include?(SendBackForm::INCORRECT_INFORMATION)
      end
    end
  end
end
