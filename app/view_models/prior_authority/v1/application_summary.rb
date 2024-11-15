module PriorAuthority
  module V1
    class ApplicationSummary < BaseViewModel
      attribute :prison_law, :boolean
      attribute :ufn, :string
      attribute :laa_reference, :string
      attribute :firm_office
      attribute :quotes
      attribute :additional_costs
      attribute :defendant
      attribute :service_type, :string
      attribute :custom_service_name, :string
      attribute :rep_order_date, :date
      attribute :submission
      attribute :main_offence_id, :string
      attribute :custom_main_offence_name, :string

      delegate :id, to: :submission

      def service_name
        if service_type == 'custom'
          custom_service_name
        else
          I18n.t("laa_crime_forms_common.prior_authority.service_types.#{service_type}")
        end
      end

      def main_offence
        if main_offence_id == 'custom'
          custom_main_offence_name
        elsif main_offence_id
          I18n.t("prior_authority.offences.#{main_offence_id}")
        end
      end

      def client_name
        "#{defendant['first_name']} #{defendant['last_name']}"
      end

      def firm_name
        firm_office['name']
      end

      def firm_account_number
        firm_office['account_number']
      end

      def date_created_str
        submission.created_at.to_fs(:stamp)
      end

      def date_updated_str
        submission.app_store_updated_at.to_fs(:stamp)
      end

      def rep_order_date_str
        rep_order_date.to_fs(:stamp)
      end

      def all_quotes
        @all_quotes ||= Quote.build(:quote, submission, 'quotes')
      end

      def built_primary_quote
        @built_primary_quote ||= all_quotes.find { |q| q.primary == true }
      end
      alias travel_cost built_primary_quote
      alias service_cost built_primary_quote

      def primary_quote
        @primary_quote ||=
          Quote.new(
            quotes.find { _1['primary'] }
                  .merge(
                    additional_cost_json: additional_costs,
                  )
          )
      end

      def formatted_total_cost
        NumberTo.pounds(primary_quote.total_cost)
      end

      def adjustments_made?
        primary_quote.total_cost != primary_quote.original_total_cost
      end

      def formatted_original_total_cost
        NumberTo.pounds(primary_quote.original_total_cost)
      end

      def current_section(current_user)
        if assessed? || expired?
          :assessed
        elsif submission.assigned_user == current_user
          :your
        else
          :open
        end
      end

      def assessed?
        submission.state.in?(PriorAuthorityApplication::ASSESSED_STATES)
      end

      delegate :sent_back?, :expired?, :provider_updated?, to: :submission

      def caseworker
        User.find_by(id: submission.assigned_user_id)&.display_name
      end
    end
  end
end
