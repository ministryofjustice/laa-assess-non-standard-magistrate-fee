module Nsm
  module Event
    class SendBack < ::Event::Decision
      def title
        t('title')
      end

      def body
        t('body')
      end
    end
  end
end
