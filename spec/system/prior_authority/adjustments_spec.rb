require 'rails_helper'

RSpec.describe 'View applications' do
  let(:caseworker) { create(:caseworker) }
  let(:application) do
    create(:prior_authority_application,
           data: build(:prior_authority_data,
                       laa_reference: 'LAA-1234',
                       additional_costs: [build(:additional_cost, description: 'Postage stamps')]))
  end

  before do
    sign_in caseworker
    visit '/'
    click_on 'Accept analytics cookies'
  end

  it 'shows the application adjustments overview' do
    visit prior_authority_application_adjustments_path(application)
    expect(page).to have_content 'Postage stamps'
  end
end
