# frozen_string_literal: true

module PriorAuthority
  module FeedbackMessages
    class FeedbackBase
      def initialize(submission, comment = '')
        @submission = submission
        @comment = comment
      end

      def template
        raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
      end

      def contents
        raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
      end
    end
  end
end
