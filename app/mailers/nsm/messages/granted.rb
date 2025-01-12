# frozen_string_literal: true

module Nsm
  module Messages
    class Granted < Base
      def template
        '80c0dcd2-597b-4c82-8c94-f6e26af71a40'
      end

      def contents
        {
          laa_case_reference: case_reference,
          ufn: ufn,
          main_defendant_name: defendant_name,
          defendant_reference: defendant_reference_string,
          claim_total: claim_total,
          date: DateTime.now.to_fs(:stamp),
        }
      end
    end
  end
end
