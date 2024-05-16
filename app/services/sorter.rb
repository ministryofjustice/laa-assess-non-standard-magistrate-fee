class Sorter
  # NOTE: applications in a 'submitted' state can be assigned and therefore "In progresss", or unassigned.
  # Unassigned applications require the visual label "Not assigned" for caseworker
  STATUS_ORDER_CLAUSE = <<-SQL.squish.freeze
  CASE WHEN state = 'submitted' THEN
         CASE WHEN users.id IS NULL THEN  'not_assigned'
         ELSE 'in_progress' END
       WHEN state = 'further_info' THEN 'sent_back'
       ELSE state END ?
  SQL

  CASEWORKER_ORDER_CLAUSE = <<-SQL.squish.freeze
    CASE WHEN users.id IS NULL THEN NULL
    ELSE users.first_name || ' ' || users.last_name END ? NULLS LAST
  SQL

  RISK_ORDER_CLAUSE = <<-SQL.squish.freeze
  CASE WHEN risk = 'high' THEN 3
       WHEN risk = 'medium' THEN 2
       ELSE 1 END ?
  SQL

  ORDERS = {
    'laa_reference' => "data->>'laa_reference' ?",
    'firm_name' => "data->'firm_office'->>'name' ?",
    'client_name' => "(data->'defendant'->>'first_name') || ' ' || (data->'defendant'->>'last_name') ?",
    'main_defendant_name' => "(defendants.value->>'first_name') || ' ' || (defendants.value->>'last_name') ?",
    'caseworker' => CASEWORKER_ORDER_CLAUSE,
    'status' => STATUS_ORDER_CLAUSE,
    'date_updated' => 'submissions.updated_at ?',
    'risk' => RISK_ORDER_CLAUSE,
    'service_name' => "data->>'service_type' ?",
  }.freeze

  DIRECTIONS = {
    'descending' => 'DESC',
    'ascending' => 'ASC',
  }.freeze

  class << self
    def call(base_query, sort_by, sort_direction)
      order_template = ORDERS[sort_by]
      direction = DIRECTIONS[sort_direction]
      base_query.then { add_joins(_1, sort_by) }.order(Arel.sql(order_template.gsub('?', direction)))
    end

    def add_joins(query, sort_by)
      with_users = query.left_joins(assignments: :user)

      return with_users unless sort_by == 'main_defendant_name'

      with_users.joins("CROSS JOIN JSONB_ARRAY_ELEMENTS(data->'defendants') as defendants")
                .where("defendants.value->>'main' = 'true'")
    end
  end
end
