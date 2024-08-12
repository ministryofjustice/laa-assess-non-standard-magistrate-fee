module Nsm
  class SearchesController < BaseController
    before_action :set_current_section

    def show
      @search_form = SearchForm.new(search_params)
      @search_form.execute if @search_form.valid?
    end

    def new
      @search_form = SearchForm.new(default_params)
      render :show
    end

    private

    def search_params
      params.require(:search_form).permit(
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
        application_type: Submission::APPLICATION_TYPES[:nsm],
        page: params.fetch(:page, '1')
      }
    end

    def set_current_section
      @current_section = :search
    end
  end
end