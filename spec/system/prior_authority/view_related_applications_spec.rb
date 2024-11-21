require 'rails_helper'

RSpec.describe 'View related applications', :stub_oauth_token do
  let(:me) { create(:caseworker) }
  let(:wanda) { create(:caseworker, first_name: 'Wanda', last_name: 'Worker') }
  let(:able) { create(:caseworker, first_name: 'Able', last_name: 'Worker') }

  let(:assigned_to_me) do
    build(:prior_authority_application,
          state: 'submitted',
          data: build(:prior_authority_data, :related_application, laa_reference: 'LAA-111'))
  end

  let(:unassigned) do
    build(
      :prior_authority_application,
      state: 'submitted',
      created_at: 4.days.ago,
      data: build(
        :prior_authority_data,
        :related_application,
        laa_reference: 'LAA-222',
        service_type: 'ae_consultant',
        defendant: { 'last_name' => 'Abrahams', 'first_name' => 'Abe' },
      )
    )
  end

  let(:in_progress) do
    build(
      :prior_authority_application,
      state: 'submitted',
      created_at: 3.days.ago,
      data: build(
        :prior_authority_data,
        :related_application,
        laa_reference: 'LAA-333',
        service_type: 'voice_recognition',
        defendant: { 'last_name' => 'Bacharach', 'first_name' => 'Burt' },
      )
    )
  end

  let(:rejected) do
    build(
      :prior_authority_application,
      state: 'rejected',
      created_at: 2.days.ago,
      data: build(
        :prior_authority_data,
        :related_application,
        laa_reference: 'LAA-444',
        defendant: { 'last_name' => 'Xerxes', 'first_name' => 'Xana' },
      )
    )
  end

  let(:granted) do
    build(
      :prior_authority_application,
      state: 'granted',
      created_at: 1.day.ago,
      data: build(
        :prior_authority_data,
        :related_application,
        laa_reference: 'LAA-555',
        defendant: { 'last_name' => 'Ziegler', 'first_name' => 'Zoe' },
      )
    )
  end

  let(:unrelated) do
    build(:prior_authority_application,
          state: 'granted',
          data: build(:prior_authority_data, laa_reference: 'LAA-xxx', ufn: '010124/001'))
  end

  let(:data_for) do
    lambda do |application|
      { application_id: application.id,
        application: application.data,
        application_type: application.application_type,
        application_state: application.state,
        last_updated_at: 1.hour.ago }
    end
  end

  let(:endpoint) { 'https://appstore.example.com/v1/submissions/searches' }

  let(:related_applications_payload) do
    {
      page: 1,
      sort_by: 'last_updated',
      sort_direction: 'descending',
      per_page: 10,
      application_type: 'crm4',
      id_to_exclude: assigned_to_me.id,
      query: assigned_to_me.data['ufn'],
      account_number: assigned_to_me.data['firm_office']['account_number']
    }
  end

  let(:laa_ref_sorted_related_applications_payload) do
    related_applications_payload.merge(sort_by: 'laa_reference', sort_direction: 'ascending')
  end

  let(:laa_ref_re_sorted_related_applications_payload) do
    laa_ref_sorted_related_applications_payload.merge(sort_direction: 'descending')
  end

  before do
    stub_app_store_interactions(assigned_to_me)
    sign_in me
    visit '/'
    click_on 'Accept analytics cookies'

    assigned_to_me.assigned_user_id = me.id
  end

  context 'when the application has NO related applications' do
    before do
      stub_request(:post, endpoint).to_return(
        status: 201,
        body: { metadata: { total_results: 0 },
                raw_data: [] }.to_json
      )
      visit prior_authority_application_path(assigned_to_me)
      click_on 'Related applications'
    end

    it 'displays expected title' do
      expect(page).to have_title('Related applications')
    end

    it 'displays info indicating the application has no related applications' do
      expect(page).to have_content('No related applications have been found')
    end
  end

  context 'when the application has related applications' do
    let(:top_row_selector) { '.govuk-table tbody tr:nth-child(1)' }

    before do
      stub_request(:post, endpoint).with(body: related_applications_payload).to_return(
        status: 201,
        body: {
          metadata: { total_results: 4 },
          raw_data: [data_for.call(granted), data_for.call(rejected), data_for.call(in_progress), data_for.call(unassigned)]
        }.to_json
      )
      stub_request(:post, endpoint).with(body: laa_ref_sorted_related_applications_payload).to_return(
        status: 201,
        body: {
          metadata: { total_results: 4 },
          raw_data: [data_for.call(unassigned), data_for.call(in_progress), data_for.call(rejected), data_for.call(granted)]
        }.to_json
      )
      stub_request(:post, endpoint).with(body: laa_ref_re_sorted_related_applications_payload).to_return(
        status: 201,
        body: {
          metadata: { total_results: 4 },
          raw_data: [data_for.call(granted), data_for.call(rejected), data_for.call(in_progress), data_for.call(unassigned)]
        }.to_json
      )

      visit prior_authority_application_path(assigned_to_me)
      click_on 'Related applications'
    end

    it 'displays the required table headers' do
      within('.govuk-table') do
        expect(page).to have_content("LAA reference\nClient\nCaseworker\nService\nLast updated\nStatus\n")
      end
    end

    it 'shows related applications' do
      within('.govuk-table') do
        expect(page).to have_content('LAA-2')
        expect(page).to have_content('LAA-3')
        expect(page).to have_content('LAA-4')
      end
    end

    it 'default sort order is newest first' do
      within(top_row_selector) do
        expect(page).to have_content('LAA-555')
      end
    end

    it 'allows me to sort by LAA reference' do
      click_on 'LAA reference'
      within(top_row_selector) do
        expect(page).to have_content('LAA-222')
      end

      click_on 'LAA reference'
      within(top_row_selector) do
        expect(page).to have_content('LAA-555')
      end
    end
  end

  context 'when the application has many related applications' do
    let(:other) do
      build_list(
        :prior_authority_application,
        11,
        state: 'submitted',
        created_at: 36.hours.ago,
        data: build(
          :prior_authority_data,
          :related_application,
          defendant: { 'last_name' => 'Geiger', 'first_name' => 'Gert' },
        )
      )
    end

    let(:second_page_payload) do
      related_applications_payload.merge(page: 2)
    end

    before do
      stub_request(:post, endpoint).with(body: related_applications_payload).to_return(
        status: 201,
        body: {
          metadata: { total_results: 11 },
          raw_data: other[0..10].map { data_for.call(_1) },
        }.to_json
      )
      stub_request(:post, endpoint).with(body: second_page_payload).to_return(
        status: 201,
        body: {
          metadata: { total_results: 11 },
          raw_data: [data_for.call(other.last)]
        }.to_json
      )

      visit prior_authority_application_path(assigned_to_me)
      click_on 'Related applications'
    end

    it 'allows me to paginate' do
      expect(page).to have_content('Showing 1 to 10 of 11 applications')
      click_on 'Next page'
      expect(page).to have_content('Showing 11 to 11 of 11 applications')
      click_on 'Previous page'
    end
  end
end
