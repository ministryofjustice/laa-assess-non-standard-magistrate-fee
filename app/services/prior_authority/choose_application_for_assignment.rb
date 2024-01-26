module PriorAuthority
  class ChooseApplicationForAssignment
    class << self
      def call(user)
        criminal_court = "CASE WHEN data->>'court_type' = 'central_criminal_court' THEN 0 ELSE 1 END as criminal_court"
        pathologist = "CASE WHEN data->>'service_type' = 'pathologist' THEN 0 ELSE 1 END as pathologist"
        PriorAuthorityApplication.unassigned(user)
                                 .select('submissions.*', criminal_court, pathologist)
                                 .order(criminal_court: :asc, pathologist: :asc, created_at: :asc)
                                 .first
      end
    end
  end
end
