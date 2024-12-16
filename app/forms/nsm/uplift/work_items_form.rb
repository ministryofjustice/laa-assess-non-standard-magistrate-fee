module Nsm
  module Uplift
    class WorkItemsForm < BaseForm
      SCOPE = 'work_items'.freeze

      class Remover < Uplift::RemoverForm
      end
    end
  end
end
