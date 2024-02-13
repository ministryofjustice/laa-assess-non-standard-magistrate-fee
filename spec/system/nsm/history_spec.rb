require 'rails_helper'

RSpec.describe 'History events' do
  let(:caseworker) { create(:caseworker) }
  let(:supervisor) { create(:supervisor) }
  let(:claim) { build(:claim, events:) }
  let(:fixed_arbitrary_date) { Time.zone.local(2023, 2, 1, 9, 0) }
  let(:events) do
    [Event::NewVersion.new(event_type: 'new_version',
                           created_at: 10.seconds.ago),
     Event::Assignment.new(primary_user_id: caseworker.id,
                           event_type: 'assignment',
                           created_at: 11.seconds.ago),
     Event::Unassignment.new(primary_user_id: caseworker.id,
                             details: { comment: 'unassignment 1' }.with_indifferent_access,
                             event_type: 'unassignment',
                             created_at: 12.seconds.ago),
     Event::Assignment.new(primary_user_id: caseworker.id,
                           event_type: 'assignment',
                           created_at: 13.seconds.ago),
     Event::ChangeRisk.new(details: { field: 'risk',
                                      comment: 'Risk change test',
                                      from: 'high',
                                      to: 'low' }.with_indifferent_access,
                           primary_user_id: caseworker.id,
                           event_type: 'change_risk',
                           created_at: 14.seconds.ago),
     Event::Note.new(primary_user_id: caseworker.id,
                     details: { comment: 'User test note' }.with_indifferent_access,
                     event_type: 'note',
                     created_at: 15.seconds.ago),
     Event::SendBack.new(primary_user_id: caseworker.id,
                         details: { field: 'state',
                                    from: 'submitted',
                                    to: 'further_info',
                                    comment: 'Send Back test' }.with_indifferent_access,
                         event_type: 'send_back',
                         created_at: 16.seconds.ago),
     Event::Decision.new(primary_user_id: caseworker.id,
                         details: { field: 'state',
                                    from: 'further_info',
                                    to: 'granted',
                                    comment: 'Decision test' }.with_indifferent_access,
                         event_type: 'decision',
                         created_at: 17.seconds.ago),
     Event::Unassignment.new(primary_user_id: caseworker.id,
                             secondary_user_id: supervisor.id,
                             details: { comment: 'unassignment 2' }.with_indifferent_access,
                             event_type: 'unassignment',
                             created_at: 18.seconds.ago)]
  end

  before do
    allow(AppStoreService).to receive_messages(list: [[], 0], get: claim, create_note: nil)
    sign_in caseworker
    visit '/'
    click_on 'Accept analytics cookies'
  end

  it 'shows all (visible) events in the history' do
    visit nsm_claim_history_path(claim)

    doc = Nokogiri::HTML(page.html)
    history = doc.css(
      '.govuk-table__body .govuk-table__cell:nth-child(2),' \
      '.govuk-table__body .govuk-table__cell:nth-child(3) p'
    ).map(&:text)

    expect(history).to eq(
      # User, Title, comment
      [
        'case worker', 'Caseworker removed from claim by super visor', 'unassignment 2',
        'case worker', 'Decision made to grant claim', 'Decision test',
        'case worker', 'Claim sent back to provider', 'Send Back test',
        'case worker', 'Caseworker note', 'User test note',
        'case worker', 'Claim risk changed to low risk', 'Risk change test',
        'case worker', 'Claim allocated to caseworker', '',
        'case worker', 'Caseworker removed self from claim', 'unassignment 1',
        'case worker', 'Claim allocated to caseworker', '',
        '', 'New claim received', ''
      ]
    )
  end

  it 'lets me add a note' do
    travel_to fixed_arbitrary_date
    visit nsm_claim_history_path(claim)
    fill_in 'Add a note to the claim history (optional)', with: 'Here is a note'
    click_on 'Add to claim history'
    expect(AppStoreService).to have_received(:create_note).with(claim,
                                                                { note: 'Here is a note', user_id: caseworker.id })
  end

  it 'rejects blank content' do
    visit nsm_claim_history_path(claim)
    click_on 'Add to claim history'
    expect(page).to have_content 'You cannot add an empty note to the claim history'
  end
end
