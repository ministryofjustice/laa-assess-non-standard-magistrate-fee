module PriorAuthority
  class ChooseApplicationForAssignment
    PATHOLOGIST_REPORT_RELATING_TO_POST_MORTEM = <<~SQL.squish.freeze
      CASE
      WHEN (data->>'service_type' = 'pathologist_report')
        AND EXISTS (
          SELECT 1 FROM JSONB_ARRAY_ELEMENTS(data->'quotes') AS quotes WHERE quotes.value->>'related_to_post_mortem' = 'true'
        ) THEN 0
      ELSE 1
      END as post_mortem_pathologist_report
    SQL

    CRIMINAL_COURT = "CASE WHEN data->>'court_type' = 'central_criminal_court' THEN 0 ELSE 1 END as criminal_court".freeze

    class << self
      def call(user)
        date_order_clause = Arel.sql("DATE_TRUNC('day', app_store_updated_at) ASC")
        PriorAuthorityApplication.assignable(user)
                                 .select('submissions.*',
                                         CRIMINAL_COURT,
                                         Arel.sql(PATHOLOGIST_REPORT_RELATING_TO_POST_MORTEM))
                                 .order(
                                   date_order_clause,
                                   criminal_court: :asc,
                                   post_mortem_pathologist_report: :asc,
                                   app_store_updated_at: :asc
                                 ).first
      end
    end
  end
end
