require 'rails_helper'

RSpec.describe 'Prior authority list views', :stub_oauth_token do
  let(:me) { create(:caseworker) }
  let(:someone_else) { create(:caseworker) }
  let(:assigned_to_me) do
    create(:prior_authority_application,
           state: 'submitted',
           updated_at: 4.days.ago,
           data: build(:prior_authority_data, laa_reference: 'LAA-111'))
  end
  let(:assigned_to_me_data) do
    { application_id: assigned_to_me.id,
      assigned_user_id: me.id,
      application: { defendant: {}, firm_office: {}, laa_reference: 'LAA-111' } }
  end
  let(:assigned_to_someone_else) do
    create(:prior_authority_application,
           state: 'submitted',
           updated_at: 3.days.ago,
           data: build(:prior_authority_data, laa_reference: 'LAA-222'))
  end
  let(:assigned_to_someone_else_data) do
    { application_id: assigned_to_someone_else.id,
      assigned_user_id: someone_else.id,
      application: { defendant: {}, firm_office: {}, laa_reference: 'LAA-222' } }
  end
  let(:unassigned) do
    create(:prior_authority_application,
           state: 'submitted',
           updated_at: 2.days.ago,
           data: build(:prior_authority_data, laa_reference: 'LAA-333'))
  end
  let(:unassigned_data) do
    { application_id: unassigned.id,
      assigned_user_id: nil,
      application: { defendant: {}, firm_office: {}, laa_reference: 'LAA-333' } }
  end
  let(:assessed) do
    create(:prior_authority_application,
           state: 'granted',
           updated_at: 1.day.ago,
           data: build(:prior_authority_data, laa_reference: 'LAA-444'))
  end
  let(:assessed_data) do
    { application_id: assessed.id,
      assigned_user_id: me.id,
      application: { defendant: {}, firm_office: {}, laa_reference: 'LAA-444' } }
  end

  let(:endpoint) { 'https://appstore.example.com/v1/submissions/searches' }

  let(:your_applications_payload) do
    {
      page: 1,
      sort_by: 'last_updated',
      sort_direction: 'descending',
      per_page: 20,
      application_type: 'crm4',
      status_with_assignment: %w[in_progress provider_updated],
      current_caseworker_id: me.id
    }
  end

  let(:open_applications_payload) do
    {
      page: 1,
      sort_by: 'last_updated',
      sort_direction: 'descending',
      per_page: 20,
      application_type: 'crm4',
      status_with_assignment: %w[not_assigned in_progress sent_back provider_updated]
    }
  end

  let(:laa_ref_open_applications_payload) do
    open_applications_payload.merge(sort_by: 'laa_reference', sort_direction: 'ascending')
  end

  let(:laa_ref_reordered_open_applications_payload) do
    laa_ref_open_applications_payload.merge(sort_direction: 'descending')
  end

  let(:closed_applications_payload) do
    {
      page: 1,
      sort_by: 'last_updated',
      sort_direction: 'descending',
      per_page: 20,
      application_type: 'crm4',
      status_with_assignment: %w[granted auto_grant rejected part_grant expired]
    }
  end

  before do
    stub_request(:post, endpoint).with(body: your_applications_payload).to_return(
      status: 201,
      body: { metadata: { total_results: 1 },
              raw_data: [assigned_to_me_data] }.to_json
    )
    stub_request(:post, endpoint).with(body: open_applications_payload).to_return(
      status: 201,
      body: { metadata: { total_results: 3 },
              raw_data: [unassigned_data, assigned_to_someone_else_data, assigned_to_me_data] }.to_json
    )
    stub_request(:post, endpoint).with(body: laa_ref_open_applications_payload).to_return(
      status: 201,
      body: { metadata: { total_results: 3 },
              raw_data: [assigned_to_me_data, assigned_to_someone_else_data, unassigned_data] }.to_json
    )
    stub_request(:post, endpoint).with(body: laa_ref_reordered_open_applications_payload).to_return(
      status: 201,
      body: { metadata: { total_results: 3 },
              raw_data: [unassigned_data, assigned_to_someone_else_data, assigned_to_me_data] }.to_json
    )
    stub_request(:post, endpoint).with(body: closed_applications_payload).to_return(
      status: 201,
      body: { metadata: { total_results: 1 },
              raw_data: [assessed_data] }.to_json
    )
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

    it 'shows in the order returned by the API' do
      expect(page.body).to match(/333.*222.*111/m)
    end

    it 'lets me sort applications' do
      click_on 'LAA reference'
      expect(page.body).to match(/111.*222.*333/m)
      click_on 'LAA reference'
      expect(page.body).to match(/333.*222.*111/m)
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
