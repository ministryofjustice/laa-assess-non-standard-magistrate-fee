module PriorAuthority
  module V1
    class Decision < BaseViewModel
      attribute :laa_reference, :string
      attribute :submission

      delegate :state, to: :submission

      def comments
        submission.events.find_by(event_type: 'Event::Decision').details['comment']
      end
    end
  end
end
