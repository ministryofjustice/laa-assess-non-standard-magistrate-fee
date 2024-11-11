require 'rails_helper'

RSpec.describe 'Overview', :stub_oauth_token, type: :system do
  let(:user) { create(:caseworker) }
  let(:claim) { create(:claim) }

  before do
    stub_request(:post, "https://appstore.example.com/v1/submissions/#{claim.id}/events").to_return(status: 201)
    stub_request(:post, "https://appstore.example.com/v1/submissions/#{claim.id}/adjustments").to_return(status: 201)
    sign_in user
    create(:assignment, submission: claim, user: user)
  end

  context 'when claim has been submitted' do
    before { visit nsm_claim_claim_details_path(claim) }

    it 'shows me the total claimed but not adjusted' do
      expect(page)
        .to have_content('Claimed: £359.76')
        .and have_no_content('Allowed:')
    end

    context 'when claim has old translation format' do
      let(:claim) { create(:claim, :legacy_translations) }

      it 'does not crash and renders the page' do
        expect(page)
          .to have_content('Counsel or agent assigned')
          .and have_no_content('Allowed:')
      end
    end
  end

  context 'when I have made a change' do
    before do
      visit nsm_claim_disbursements_path(claim)
      click_on 'Accountants'
      fill_in 'Change disbursement cost', with: '0'
      fill_in 'Explain your decision', with: 'Testing'
      click_on 'Save changes'
    end

    it 'shows me the total claimed and total adjusted' do
      expect(page)
        .to have_content('Claimed: £359.76')
        .and have_content('Allowed: £259.76')
    end
  end

  context 'when claim has been assessed as granted' do
    before { visit nsm_claim_claim_details_path(claim) }

    let(:claim) { create(:claim, state: 'granted') }

    it 'shows me the total claimed and total adjusted' do
      expect(page)
        .to have_content('Claimed: £359.76')
        .and have_content('Allowed: £359.76')
    end
  end

  context 'when claim has been assessed as part granted' do
    let(:claim) { create(:claim, state: 'part_grant') }

    before do
      claim.data['assessment_comment'] = 'Part grant reason'
      claim.save!
      visit nsm_claim_claim_details_path(claim)
    end

    it 'shows me the decision, comment and review adjustments link' do
      expect(page)
        .to have_selector('strong', text: 'Part granted')
        .and have_content('Part grant reason')
        .and have_link('Review quote adjustments')
    end
  end

  context 'when claim has been sent back and expired' do
    let(:claim) { create(:claim, state: 'expired') }

    before do
      claim.data['assessment_comment'] = 'Send back reason'
      claim.data['further_information'] = [
        {
          documents: [],
          requested_at: DateTime.new(2024, 9, 1, 10, 10, 10),
          information_requested: 'Send back reason'
        }
      ]
      claim.save!
      visit nsm_claim_claim_details_path(claim)
    end

    it 'shows me the status and comment' do
      expect(page)
        .to have_content('Expired')
        .and have_content('Send back reason')
    end
  end

  context 'further information requested' do
    let(:claim) { create(:claim, state: 'provider_updated') }
    let(:further_information) do
      [
        {
          'documents' => [
            {
              'file_name' => 'Some_Info.pdf',
              'file_path' => '421727bc53d347ea81edd6a00833671d',
              'file_size' => 690_389,
              'file_type' => 'application/pdf',
              'document_type' => 'supporting_document'
            },
            {
              'file_name' => 'Some_Info2.pdf',
              'file_path' => '421727bc53d347ea81edd6a00833671d',
              'file_size' => 690_389,
              'file_type' => 'application/pdf',
              'document_type' => 'supporting_document'
            }
          ],
          'requested_at' => '2024-08-22T09:42:53.151Z',
          'caseworker_id' => user.id,
          'information_supplied' => 'Added some stuff',
          'information_requested' => 'Example information requested by caseworker'
        },
      ]
    end

    before do
      claim.data['further_information'] = further_information
      claim.data['updated_at'] = DateTime.new(2024, 9, 1, 10, 10, 10)
      claim.save!
      allow(FeatureFlags).to receive(:nsm_rfi_loop).and_return(
        instance_double(FeatureFlags::EnabledFeature, enabled?: true)
      )
      visit nsm_claim_claim_details_path(claim)
    end

    it 'shows me state, section header and further information link' do
      expect(page)
        .to have_selector('strong', text: 'Provider updated')
        .and have_selector('h2', text: 'Provider updates')
        .and have_link('Further information')
        .and have_link('Some_Info.pdf')
        .and have_link('Some_Info2.pdf')
    end

    it 'lets me download files' do
      click_on('Some_Info.pdf')
      expect(page).to have_current_path(
        %r{/421727bc53d347ea81edd6a00833671d\?response-content-disposition=attachment%3B%20filename%3D%22Some_Info.pdf}
      )
    end
  end
end
