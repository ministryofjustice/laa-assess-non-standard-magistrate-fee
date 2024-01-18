require 'rails_helper'

RSpec.describe 'History events' do
  let(:caseworker) { create(:caseworker) }

  before do
    sign_in caseworker
    visit '/'
    click_on 'Accept analytics cookies'
  end

  it 'shows all (visible) events in the history' do
    claim = create(:claim)
    supervisor = create(:supervisor)

    Event::NewVersion.build(crime_application: claim)
    Event::Assignment.build(crime_application: claim, current_user: caseworker)
    Event::Unassignment.build(crime_application: claim, user: caseworker, current_user: caseworker,
                              comment: 'unassignment 1')
    Event::Assignment.build(crime_application: claim, current_user: caseworker)
    Event::ChangeRisk.build(crime_application: claim, explanation: 'Risk change test', previous_risk_level: 'high',
                            current_user: caseworker)
    Event::Note.build(crime_application: claim, current_user: caseworker, note: 'User test note')
    claim.state = 'further_info'
    Event::SendBack.build(crime_application: claim, current_user: caseworker, previous_state: 'submitted',
                          comment: 'Send Back test')
    claim.state = 'granted'
    Event::Decision.build(crime_application: claim, current_user: caseworker, previous_state: 'further_info',
                          comment: 'Decision test')
    Event::Unassignment.build(crime_application: claim, user: caseworker, current_user: supervisor,
                              comment: 'unassignment 2')

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
end
