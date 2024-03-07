require 'rails_helper'

RSpec.describe 'View applications' do
  let(:caseworker) { create(:caseworker) }
  let(:application) do
    create(
      :prior_authority_application,
      created_at: '2023-3-2',
      data: build(
        :prior_authority_data,
        laa_reference: 'LAA-1234',
        additional_costs: build_list(
          :additional_cost,
          1,
          unit_type: 'per_item',
          items: 2,
          cost_per_item: '35.0'
        ),
        quotes: [
          build(
            :primary_quote,
            cost_type: 'per_hour',
            period: 180,
            cost_per_hour: '3.50',
            travel_time: nil,
            travel_cost_per_hour: nil
          ),
          build(:alternative_quote)
        ]
      )
    )
  end

  before do
    sign_in caseworker
    visit '/'
    click_on 'Accept analytics cookies'
    visit prior_authority_root_path
  end

  context 'when an application is already assigned to me' do
    before do
      create(:assignment, user: caseworker, submission: application)
      click_on 'Start now'
    end

    it 'shows me that application in the list' do
      expect(page).to have_content 'LAA-1234'
    end

    context 'when I click through to the application details' do
      before { click_on 'LAA-1234' }

      it 'shows summary details' do
        expect(page).to have_current_path prior_authority_application_path(application)
        expect(page).to have_content('LAA-1234')
        expect(page).to have_content(
          "Requested: £80.50\nService: Pathologist report " \
          "Representation order date: 02 January 2023\nDate received: 02 March 2023"
        )
      end

      it 'shows application details card' do
        within('.govuk-summary-card', text: 'Application details') do
          expect(page).to have_content "LAA referenceLAA-1234\nPrison LawNo"
        end
      end

      it 'shows primary quote card' do
        within('#primary-quote.govuk-summary-card') do
          expect(page).to have_content "Service requiredPathologist report\n" \
                                       "Service detailsABC DEFABC, SW1 1AA\n" \
                                       "Quote uploadtest.pdf\n" \
                                       'Existing prior authority grantedYes'
          expect(page).to have_content 'Cost typeAmountRequestedTotal' \
                                       'Service3 hours 0 minutes£3.50£10.50' \
                                       'ABC2 items£35.00£70.00'
        end
      end

      it 'shows reason why card' do
        within('.govuk-summary-card', text: 'Reason for prior authority') do
          expect(page).to have_content 'Supporting documentsNone'
        end
      end

      it 'shows alternative quote card' do
        within('.govuk-summary-card', text: 'Alternative quote 1') do
          expect(page).to have_content "Service detailsABC DEFABC, SW1 1AA\n" \
                                       "Quote uploadNone\nAdditional itemsFooBar"
          expect(page).to have_content 'Cost typeAlternative quotePrimary quote' \
                                       'Service£10.50£10.50' \
                                       'Travel£300.00£0.00' \
                                       'Additional£100.00£70.00' \
                                       'Total cost£410.50£80.50'
        end
      end

      it 'shows client details card' do
        within('.govuk-summary-card', text: 'Client details') do
          expect(page).to have_content "Client nameJoe Bloggs\nDate of birth01 January 1950"
        end
      end

      it 'shows case details card' do
        within('.govuk-summary-card', text: 'Case details') do
          expect(page).to have_content "Main offenceRobbery\n" \
                                       "Date of representation order02 January 2023\n" \
                                       "Client detainedNo\n" \
                                       'Subject to POCANo'
        end
      end

      it 'shows hearing details card' do
        within('.govuk-summary-card', text: 'Hearing details') do
          expect(page).to have_content "Date of next hearing01 January 2025\n" \
                                       "Likely or actual pleaGuilty\n" \
                                       'Court typeCrown Court (excluding Central Criminal Court)'
        end
      end

      it 'shows case contact card' do
        within('.govuk-summary-card', text: 'Case contact') do
          expect(page).to have_content "Case contactJane Doejane@doe.com\nFirm detailsLegalCo"
        end
      end

      it 'lets me view associated files' do
        click_on 'test.pdf'
        expect(page).to have_current_path(
          %r{/123123123\?response-content-disposition=attachment%3B%20filename%3Dtest\.pdf}
        )
      end
    end
  end
end
