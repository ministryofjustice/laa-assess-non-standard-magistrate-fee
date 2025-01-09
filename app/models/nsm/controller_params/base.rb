module Nsm
  module ControllerParams
    class Base
      include ActiveModel::Model
      include ActiveModel::Attributes

      def error_summary
        errors.messages.map { |key, value| "Field: #{key}, Errors: #{value}" }
      end
    end
  end
end
