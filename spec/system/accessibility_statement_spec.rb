require 'rails_helper'

RSpec.describe 'Accessibility statement' do
  before do
    sign_in create(:caseworker)
    visit root_path
    click_on 'Accessibility statement'
  end

  it 'lets me view the Accessibility statement' do
    expect(page).to have_title('Accessibility statement')
    expect(page).to have_css('h1', text: 'Accessibility statement')
  end
end
