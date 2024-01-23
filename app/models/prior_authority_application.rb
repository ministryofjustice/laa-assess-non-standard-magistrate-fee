class PriorAuthorityApplication < Submission
  default_scope -> { where(application_type: APPLICATION_TYPES[:prior_authority]) }
end
