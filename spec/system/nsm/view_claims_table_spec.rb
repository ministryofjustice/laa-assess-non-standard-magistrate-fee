require 'rails_helper'

RSpec.describe 'NSM tables' do
  let(:me) { create(:caseworker, first_name: 'Bob') }
  let(:someone_else) { create(:caseworker, first_name: 'Zob') }
  let(:assigned_to_me) do
    create(:claim,
           state: 'submitted',
           laa_reference: 'LAA-assigned-to-me',
           defendants: [
             {
               'main' =>  true,
               'first_name' =>  'Acy',
               'last_name' => 'Inklater'
             },
             {
               'main' =>  false,
               'first_name' =>  'Zacy',
               'last_name' => 'Zinklater'
             }
           ])
  end
  let(:assigned_to_someone_else) do
    create(:claim,
           state: 'further_info',
           laa_reference: 'LAA-assigned-to-someone-else',
           defendants: [
             {
               'main' =>  true,
               'first_name' =>  'Macy',
               'last_name' => 'Minklater'
             }
           ])
  end
  let(:unassigned) do
    create(:claim,
           state: 'submitted',
           laa_reference: 'LAA-unassigned',
           defendants: [
             {
               'main' =>  true,
               'first_name' =>  'Tracy',
               'last_name' => 'Tinklater'
             }
           ])
  end
  let(:assessed) do
    create(:claim,
           state: 'granted',
           laa_reference: 'LAA-assesed',
           defendants: [
             {
               'main' =>  true,
               'first_name' =>  'Gracy',
               'last_name' => 'Ginklater'
             }
           ])
  end

  before do
    create(:assignment, user: me, submission: assigned_to_me)
    create(:assignment, user: me, submission: assessed)
    create(:assignment, user: someone_else, submission: assigned_to_someone_else)
    unassigned
    assessed
    sign_in me
  end

  context 'when I visit open claims' do
    before { visit open_nsm_claims_path }

    it 'only shows me non-claims applications' do
      expect(page).to have_content 'LAA-assigned-to-me'
      expect(page).to have_content 'LAA-assigned-to-someone-else'
      expect(page).to have_content 'LAA-unassigned'
      expect(page).to have_no_content 'LAA-assessed'
    end

    it 'lets me sort claims by main defendant' do
      click_on 'Defendant'
      expect(page.body).to match(/Acy.*Macy.*Tracy/m)
      click_on 'Defendant'
      expect(page.body).to match(/Tracy.*Macy.*Acy/m)
    end

    it 'lets me sort claims by caseworker' do
      click_on 'Defendant'
      expect(page.body).to match(/Bob.*Zob.*Not assigned/m)
      click_on 'Defendant'
      expect(page.body).to match(/Not assigned.*Zob.*Bob/m)
    end
  end
end
