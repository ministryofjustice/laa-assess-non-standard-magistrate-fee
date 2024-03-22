require 'rails_helper'

RSpec.describe 'Prior authority list views' do
  let(:me) { create(:caseworker) }
  let(:someone_else) { create(:caseworker) }
  let(:assigned_to_me) do
    create(:prior_authority_application,
           state: 'submitted',
           data: build(:prior_authority_data, laa_reference: 'LAA-111'))
  end
  let(:assigned_to_someone_else) do
    create(:prior_authority_application,
           state: 'submitted',
           data: build(:prior_authority_data, laa_reference: 'LAA-222'))
  end
  let(:unassigned) do
    create(:prior_authority_application,
           state: 'submitted',
           data: build(:prior_authority_data, laa_reference: 'LAA-333'))
  end
  let(:assessed) do
    create(:prior_authority_application,
           state: 'granted',
           data: build(:prior_authority_data, laa_reference: 'LAA-444'))
  end

  before do
    create(:assignment, user: me, submission: assigned_to_me)
    create(:assignment, user: me, submission: assessed)
    create(:assignment, user: someone_else, submission: assigned_to_someone_else)
    unassigned
    assessed
    sign_in me
  end

  context 'when I visit your applications' do
    before { visit your_prior_authority_applications_path }

    it 'only shows me unassessed applications assigned to me' do
      expect(page).to have_content 'LAA-1'
      expect(page).to have_no_content 'LAA-2'
      expect(page).to have_no_content 'LAA-3'
      expect(page).to have_no_content 'LAA-4'
    end
  end

  context 'when I visit open applications' do
    before { visit open_prior_authority_applications_path }

    it 'only shows me non-assessed applications' do
      expect(page).to have_content 'LAA-1'
      expect(page).to have_content 'LAA-2'
      expect(page).to have_content 'LAA-3'
      expect(page).to have_no_content 'LAA-4'
    end

    it 'lets me sort applications' do
      click_on 'LAA reference'
      expect(page.body).to match(/333.*222.*111/m)
      click_on 'LAA reference'
      expect(page.body).to match(/111.*222.*333/m)
    end
  end

  context 'when I visit closed applications' do
    before { visit closed_prior_authority_applications_path }

    it 'only shows me closed applications' do
      expect(page).to have_no_content 'LAA-1'
      expect(page).to have_no_content 'LAA-2'
      expect(page).to have_no_content 'LAA-3'
      expect(page).to have_content 'LAA-4'
    end
  end
end
