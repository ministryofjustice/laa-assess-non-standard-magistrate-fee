require 'rails_helper'

RSpec.describe 'View related applications' do
  let(:me) { create(:caseworker) }
  let(:wanda) { create(:caseworker, first_name: 'Wanda', last_name: 'Worker') }
  let(:able) { create(:caseworker, first_name: 'Able', last_name: 'Worker') }

  let(:assigned_to_me) do
    create(:prior_authority_application,
           state: 'in_progress',
           data: build(:prior_authority_data, :related_application, laa_reference: 'LAA-111'))
  end

  let(:unassigned) do
    create(
      :prior_authority_application,
      state: 'submitted',
      created_at: 4.days.ago,
      data: build(
        :prior_authority_data,
        :related_application,
        laa_reference: 'LAA-222',
        defendant: { 'last_name' => 'Abrahams', 'first_name' => 'Abe' },
      )
    )
  end

  let(:in_progress) do
    create(
      :prior_authority_application,
      state: 'in_progress',
      created_at: 3.days.ago,
      data: build(
        :prior_authority_data,
        :related_application,
        laa_reference: 'LAA-333',
        defendant: { 'last_name' => 'Bacharach', 'first_name' => 'Burt' },
      )
    )
  end

  let(:rejected) do
    create(
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
    create(
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
    create(:prior_authority_application,
           state: 'granted',
           data: build(:prior_authority_data, laa_reference: 'LAA-xxx', ufn: '010124/001'))
  end

  before do
    sign_in me
    visit '/'
    click_on 'Accept analytics cookies'

    create(:assignment,
           user: me,
           submission: assigned_to_me)

    visit prior_authority_root_path
    click_on 'Start now'
  end

  context 'when the application has NO related applications' do
    before do
      click_on 'LAA-111'
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
    before do
      unassigned
      in_progress
      rejected
      granted

      create(:assignment, user: wanda, submission: in_progress)
      create(:assignment, user: able, submission: rejected)
      create(:assignment, user: able, submission: granted)

      click_on 'LAA-111'
      click_on 'Related applications'
    end

    it 'displays the required table headers' do
      within('.govuk-table') do
        expect(page).to have_content("LAA reference\nClient\nCaseworker\nService\nReceived\nStatus\n")
      end
    end

    it 'does NOT show the current application or unrelated applications' do
      within('.govuk-table') do
        expect(page).to have_no_content('LAA-1')
        expect(page).to have_no_content('LAA-x')
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
        expect(page).to have_content('LAA-555')
      end

      click_on 'LAA reference'
      within(top_row_selector) do
        expect(page).to have_content('LAA-222')
      end
    end

    it 'allows me to sort by client name' do
      click_on 'Client'
      within(top_row_selector) do
        expect(page).to have_content('Zoe Ziegler')
      end

      click_on 'Client'
      within(top_row_selector) do
        expect(page).to have_content('Abe Abrahams')
      end
    end

    it 'allows me to sort by case worker name' do
      click_on 'Caseworker'
      within(top_row_selector) do
        expect(page).to have_content('Wanda Worker')
      end

      click_on 'Caseworker'
      within(top_row_selector) do
        expect(page).to have_content('Able Worker')
      end
    end

    it 'allows me to sort by received date' do
      click_on 'Received'
      within(top_row_selector) do
        expect(page).to have_content('LAA-555')
      end

      click_on 'Received'
      within(top_row_selector) do
        expect(page).to have_content('LAA-222')
      end
    end

    it 'allows me to sort by status' do
      click_on 'Status'
      within(top_row_selector) do
        expect(page).to have_content('Rejected')
      end

      click_on 'Status'
      within(top_row_selector) do
        expect(page).to have_content('Granted')
      end
    end

    def top_row_selector
      '.govuk-table tbody tr:nth-child(1)'
    end
  end

  context 'when the application has many related applications' do
    let(:other) do
      create_list(
        :prior_authority_application,
        10,
        state: 'submitted',
        created_at: 36.hours.ago,
        data: build(
          :prior_authority_data,
          :related_application,
          defendant: { 'last_name' => 'Geiger', 'first_name' => 'Gert' },
        )
      )
    end

    before do
      in_progress
      other

      click_on 'LAA-111'
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
