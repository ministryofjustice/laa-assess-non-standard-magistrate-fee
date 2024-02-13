require 'rails_helper'

RSpec.describe 'View applications' do
  let(:caseworker) { create(:caseworker) }
  let(:application) do
    build(:prior_authority_application,
          data: build(:prior_authority_data, laa_reference: 'LAA-1234').with_indifferent_access)
  end

  before do
    allow(AppStoreService).to receive(:list) do |params|
      if params[:application_type] == 'crm7'
        [[], 0]
      else
        [[application], 1]
      end
    end
    sign_in caseworker
    visit '/'
    click_on 'Accept analytics cookies'
    visit prior_authority_root_path
  end

  it 'shows the application overview' do
    visit prior_authority_root_path
    click_on 'Start now'
    expect(page).to have_content 'LAA-1234'
  end
end
