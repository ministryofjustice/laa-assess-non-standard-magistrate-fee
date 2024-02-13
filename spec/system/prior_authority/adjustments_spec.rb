require 'rails_helper'

RSpec.describe 'View applications' do
  let(:caseworker) { create(:caseworker) }
  let(:application) do
    build(:prior_authority_application,
          data: build(:prior_authority_data,
                      laa_reference: 'LAA-1234',
                      additional_costs: [build(:additional_cost,
                                               id: '123',
                                               description: 'Postage stamps')]).with_indifferent_access)
  end

  before do
    allow(AppStoreService).to receive_messages(list: [[], 0], get: application, adjust: nil)
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
    expect(AppStoreService).to have_received(:adjust).with(
      application,
      { change_detail_sets: [{ change: 137,
           comment: 'typoe',
           field: 'time_spent',
           from: 60,
           to: 197 }],
        linked_id: '123',
        linked_type: 'work_items',
        user_id: caseworker.id }
    )
  end
end
