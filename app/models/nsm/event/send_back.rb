module Nsm
  module Event
    class SendBack < ::Event::Decision
      def title
        t('title')
      end
    end
  end
end
