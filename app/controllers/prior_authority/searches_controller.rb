module PriorAuthority
  class SearchesController < BaseController
    def show
      authorize(PriorAuthorityApplication, :index?)
      @search_form = PriorAuthority::SearchForm.new(search_params)
      @search_form.execute if @search_form.valid?
    end

    def new
      authorize(PriorAuthorityApplication, :index?)
      @search_form = PriorAuthority::SearchForm.new(default_params)
      render :show
    end

    private

    def search_params
      params.require(:prior_authority_search_form).permit(
        :query,
        :submitted_from,
        :submitted_to,
        :updated_from,
        :updated_to,
        :status_with_assignment,
        :caseworker_id,
        :sort_by,
        :sort_direction
      ).merge(default_params)
    end

    def default_params
      {
        application_type: Submission::APPLICATION_TYPES[:prior_authority],
        page: params.fetch(:page, '1')
      }
    end
  end
end
