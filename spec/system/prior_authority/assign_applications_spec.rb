require 'rails_helper'

RSpec.describe 'Assign applications' do
  let(:caseworker) { create(:caseworker) }

  before do
    allow(AppStoreService).to receive_messages(list: [[], 0], assign: application)
    sign_in caseworker
    visit '/'
    click_on 'Accept analytics cookies'
    visit prior_authority_root_path
    click_on 'Start now'
    application
    click_on 'Assess next application'
  end

  context 'when there is an application' do
    let(:application) { build(:prior_authority_application) }

    it 'lets me assign the application to myself' do
      expect(page).to have_current_path(prior_authority_application_path(application))
    end
  end

  context 'when there is no application' do
    let(:application) { nil }

    it 'shows me an explanation' do
      click_on 'Assess next application'
      expect(page).to have_content 'There are no applications waiting to be allocated'
    end
  end
end
