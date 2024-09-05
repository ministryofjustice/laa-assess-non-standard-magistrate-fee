module Nsm
  class RelatedApplications
    class << self
      def call(ufn, account_number)
        NsmApplication
          .where("data->>'ufn' = :ufn", ufn:)
          .where("data->'firm_office'->>'account_number' = :account_number", account_number:)
      end
    end
  end
end
