require 'rails_helper'

RSpec.describe 'Supporting Evidence' do
  let(:user) { create(:caseworker) }
  let(:claim) { create(:claim) }

  before do
    sign_in user
    visit claim_supporting_evidences_path(claim)
  end

  context 'There is supporting evidence and nothing is sent by post' do
    it 'can view supporting evidence table' do
      within('.govuk-table__row', text: 'Advocacy evidence _ Tom_TC.pdf') do
        expect(page).to have_content(
          'Advocacy evidence _ Tom_TC.pdf' \
          'Monday18 September 2023'
        )
      end
    end

    it 'no send by post info shown' do
      expect(page).to have_no_content('The provider has chosen to post the evidence to:')
    end
  end

  context 'There is supporting evidence and some evidence is sent by post' do
    let(:claim) { create(:claim, :sent_by_post_true_with_evidence) }

    it 'can view supporting evidence table' do

      within('.govuk-table__row', text: 'Advocacy evidence _ Tom_TC.pdf') do
        expect(page).to have_content(
          'Advocacy evidence _ Tom_TC.pdf' \
          'Monday18 September 2023'
        )
      end
    end

    it 'send by post info is shown' do
      expect(page).to have_content('The provider has chosen to post the evidence to:')
    end
  end

  context 'There is supporting evidence sent by post' do
    let(:claim) { create(:claim, :sent_by_post_true_without_evidence) }

    it 'supporting evidence table not shown' do
      expect(page).to have_no_selector('.govuk-table__row')
    end


    it 'send by post info is shown' do
      expect(page).to have_content('The provider has chosen to post the evidence to:')
    end
  end
end
