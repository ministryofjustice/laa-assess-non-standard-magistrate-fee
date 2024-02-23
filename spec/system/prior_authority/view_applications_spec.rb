require 'rails_helper'

RSpec.describe 'View applications' do
  let(:caseworker) { create(:caseworker) }

  before do
    sign_in caseworker
    visit '/'
    click_on 'Accept analytics cookies'
    visit prior_authority_root_path
  end

  it 'shows the application overview' do
    application = create(
      :prior_authority_application,
      data: build(
        :prior_authority_data,
        laa_reference: 'LAA-1234',
        additional_costs: build_list(
          :additional_cost,
          1,
          unit_type: 'per_item',
          items: 2,
          cost_per_item: '35.0'
        ),
        quotes: build_list(
          :primary_quote,
          1,
          cost_type: 'per_hour',
          period: 180,
          cost_per_hour: '3.50',
          travel_time: nil,
          travel_cost_per_hour: nil
        )
      )
    )
    create(:assignment,
           user: caseworker,
           submission: application)
    visit prior_authority_root_path
    click_on 'Start now'
    expect(page).to have_content 'LAA-1234'
    click_on 'LAA-1234'
    expect(page).to have_current_path prior_authority_application_path(application)
    expect(page).to have_content 'Requested: £80.50'
  end
end
