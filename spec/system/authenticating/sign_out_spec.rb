require 'rails_helper'

RSpec.describe 'Sign out' do
  let(:user) { create(:caseworker) }

  before do
    sign_in user
    visit '/'
    click_on('Sign out')
  end

  it 'signs the user out' do
    expect(page).to have_no_content 'Your list'
  end

  it 'shows the notification banner' do
    expect(page).to have_content('Sign in to access the service')
  end
end
