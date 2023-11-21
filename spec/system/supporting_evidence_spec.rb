require 'rails_helper'

RSpec.describe 'Supporting Evidence' do
  let(:user) { create(:caseworker) }
  let(:claim) { create(:claim) }

  before do
    sign_in user
  end

  context 'There is supporting evidence and nothing is sent by post' do
    it 'can view supporting evidence table' do
      visit claim_supporting_evidences_path(claim)
      save_and_open_page

      within('.govuk-table__row', text: 'Advocacy evidence _ Tom_TC.pdf') do
        expect(page).to have_content(
          'Advocacy evidence _ Tom_TC.pdf' \
          'Monday18 September 2023'
        )
      end
    end
  end

  # context 'There is supporting evidence and some evidence is sent by post' do

  # end

  # context 'There is supporting evidence sent by post' do

  # end
end
