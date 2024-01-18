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
    application = create(:prior_authority_application,
                         data: build(:prior_authority_data, laa_reference: 'LAA-1234'))
    create(:assignment,
           user: caseworker,
           submission: application)
    visit prior_authority_root_path
    click_on 'Start now'
    expect(page).to have_content 'LAA-1234'
  end
end
