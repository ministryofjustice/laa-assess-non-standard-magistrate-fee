require 'rails_helper'

RSpec.describe 'Assign applications' do
  let(:caseworker) { create(:caseworker) }

  before do
    sign_in caseworker
    visit '/'
    click_on 'Accept analytics cookies'
    visit prior_authority_root_path
    click_on 'Start now'
  end

  it 'lets me assign an application to myself' do
    application = create(:prior_authority_application)
    click_on 'Assess next application'
    # As the UI has not yet been built, the most we can do is demonstrate that an assignment has been made
    expect(application.reload.assignments.first.user).to eq caseworker
    expect(application.events.first).to be_an Event::Assignment
  end

  it 'copes if there is no application' do
    click_on 'Assess next application'
    expect(page).to have_content 'There are no applications waiting to be allocated'
  end
end
