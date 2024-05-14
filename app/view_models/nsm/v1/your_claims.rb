module Nsm
  module V1
    class YourClaims < BaseViewModel
      attribute :laa_reference
      attribute :defendants
      attribute :firm_office
      attribute :submission
      attribute :risk
      delegate :created_at, to: :submission

      def main_defendant_name
        main_defendant = defendants.detect { |defendant| defendant['main'] }
        main_defendant ? construct_name(main_defendant) : ''
      end

      def firm_name
        firm_office['name']
      end

      def date_created_str
        I18n.l(created_at, format: '%-d %b %Y')
      end

      def date_created_sort
        created_at.to_fs(:db)
      end

      def risk_sort
        {
          'high' => 1,
          'medium' => 2,
          'low' => 3,
        }[risk]
      end

      def state
        @state ||= if submission.sent_back?
                     submission.state
                   else
                     'in_progress'
                   end
      end

      def tag_colour
        case state
        when 'in_progress'
          'purple'
        else
          'yellow'
        end
      end
    end
  end
end
