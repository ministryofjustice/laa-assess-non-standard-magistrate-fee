module Nsm
  class SearchForm < ::SearchForm
    def statuses
      status_list = %i[not_assigned
                       in_progress
                       sent_back
                       provider_updated
                       granted
                       part_grant
                       rejected
                       expired]

      relevant_statuses = if FeatureFlags.nsm_rfi_loop.enabled?
                            status_list
                          else
                            status_list - %i[provider_updated expired]
                          end

      [show_all] + relevant_statuses.map { Option.new(_1, I18n.t("search.statuses.#{_1}")) }
    end
  end
end
