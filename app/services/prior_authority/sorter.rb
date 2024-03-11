module PriorAuthority
  class Sorter
    STATUS_ORDER_CLAUSE = <<-SQL.squish.freeze
    CASE WHEN state = 'submitted' THEN
           CASE WHEN users.id IS NULL THEN  'not_assigned'
           ELSE 'in_progress' END
         ELSE state END ?
    SQL

    ORDERS = {
      'laa_reference' => "data->>'laa_reference' ?",
      'firm_name' => "data->>'firm_name' ?",
      'client_name' => "data->>'client_name' ?",
      'date_received' => 'submissions.created_at ?',
      'caseworker' => 'users.last_name ?, users.first_name ?',
      # 'submitted' state has visual label "Not assigned" or "In progress",
      # so correct for that when ordering alphabetically
      'status' => STATUS_ORDER_CLAUSE,
      'date_assessed' => 'submissions.updated_at ?'
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
