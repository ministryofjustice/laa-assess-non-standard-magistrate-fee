# Base class to allow remove uplift from all to work for
# letters and calls and work items. The subclass must implement
# * SCOPE - constant to get the list of record being processed from the JSON
# * Remover - class (inherited from `RemoverForm`) with required setup
module Nsm
  module Uplift
    class BaseForm
      include ActiveModel::Model
      include ActiveModel::Attributes
      include ActiveRecord::AttributeAssignment

      attribute :claim
      attribute :explanation, :string
      attribute :current_user

      validates :claim, presence: true
      validates :explanation, presence: true

      def save!
        return false unless valid?

        Claim.transaction do
          change_local_data

          AppStoreClient.new.adjust(claim)
        end

        true
      rescue StandardError
        false
      end

      def change_local_data
        claim.data[self.class::SCOPE].each do |selected_record|
          row = self.class::Remover.new(claim: claim,
                                        explanation: explanation_for(selected_record),
                                        current_user: current_user,
                                        selected_record: selected_record)
          next unless row.valid?

          row.save
        end

        claim.save!
      end

      def explanation_for(record)
        [record['adjustment_comment'].presence, explanation].compact.join("\n\n")
      end
    end
  end
end
