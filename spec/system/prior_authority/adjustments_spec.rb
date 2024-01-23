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

  it 'shows an error if I make an adjustment without an explanation' do
    visit prior_authority_application_adjustments_path(application)
    click_on 'Adjust additional cost'
    fill_in 'Hours', with: '3'
    click_on 'Save changes'
    expect(page).to have_content 'Add an explanation for your decision'
  end

  it 'lets me adjust an additional cost' do
    visit prior_authority_application_adjustments_path(application)
    click_on 'Adjust additional cost'
    fill_in 'Hours', with: '3'
    fill_in 'Minutes', with: '17'
    fill_in 'Explanation', with: 'typoe'
    click_on 'Save changes'
    expect(page).to have_content '3 Hrs 17 Mins'
  end
end
