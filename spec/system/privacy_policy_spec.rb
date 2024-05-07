require 'rails_helper'

RSpec.describe 'Privacy policy' do
  before do
    sign_in create(:caseworker)
    visit root_path
    click_on 'Privacy policy'
  end

  it 'lets me view the privacy policy' do
    expect(page).to have_title('Privacy policy')
    expect(page).to have_css('h1', text: 'Privacy policy')
    expect(page).to have_content('This privacy notice sets out')
  end
end
