module PriorAuthority
  class Sorter
    # NOTE: applications in a 'submitted' state can be assigned and therefore "In progresss", or unassigned.
    # Unassigned applications require the visual label "Not assigned" for caseworker
    STATUS_ORDER_CLAUSE = <<-SQL.squish.freeze
    CASE WHEN state = 'submitted' THEN
           CASE WHEN users.id IS NULL THEN  'not_assigned'
           ELSE 'in_progress' END
         ELSE state END ?
    SQL

    ORDERS = {
      'laa_reference' => "data->>'laa_reference' ?",
      'firm_name' => "data->'firm_office'->>'name' ?",
      'client_name' => "(data->'defendant'->>'first_name') || ' ' || (data->'defendant'->>'last_name') ?",
      'caseworker' => "COALESCE(users.first_name, 'Not') || ' ' || COALESCE(users.last_name, 'assigned') ?",
      'status' => STATUS_ORDER_CLAUSE,
      'date_updated' => 'submissions.updated_at ?',
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
        base_query.left_joins(assignments: :user).order(Arel.sql(order_template.gsub('?', direction)))
      end
    end
  end
end
