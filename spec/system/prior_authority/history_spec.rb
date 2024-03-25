require 'rails_helper'

RSpec.describe 'History events' do
  let(:caseworker) { create(:caseworker) }
  let(:application) { create(:prior_authority_application, state: 'granted') }
  let(:fixed_arbitrary_date) { Time.zone.local(2023, 2, 1, 9, 0) }
  let(:supervisor) { create(:supervisor) }

  before do
    travel_to fixed_arbitrary_date
    application
    sign_in caseworker

    Event::NewVersion.build(submission: application).update(created_at: 10.hours.ago)
    Event::Assignment.build(submission: application, current_user: caseworker).update(created_at: 9.hours.ago)
    Event::Unassignment.build(submission: application, user: caseworker, current_user: supervisor,
                              comment: 'unassignment comment').update(created_at: 8.hours.ago)
    Event::Assignment.build(submission: application, current_user: supervisor,
                            comment: 'manual assignment comment').update(created_at: 7.hours.ago)
    Event::DraftDecision.build(submission: application, current_user: caseworker, next_state: 'rejected',
                               comment: 'draft decision comment').update(created_at: 6.hours.ago)
    Event::Decision.build(submission: application, current_user: caseworker, previous_state: 'submitted',
                          comment: 'decision comment').update(created_at: 5.hours.ago)
    PriorAuthority::Event::DraftSendBack.build(submission: application,
                                               current_user: caseworker,
                                               comments: { further_information: 'draft send back comment' },
                                               updates_needed: ['further_information']).update(created_at: 4.hours.ago)
    PriorAuthority::Event::SendBack.build(submission: application,
                                          current_user: caseworker,
                                          comments: { further_information: 'send back comment' },
                                          updates_needed: ['further_information']).update(created_at: 3.hours.ago)
    Event::ProviderUpdated.create!(submission: application,
                                   details: { comment: 'Foo', corrected_info: ['bar'] },
                                   created_at: 2.hours.ago)
    Event::ProviderUpdated.create!(submission: application,
                                   details: {  corrected_info: ['bar'] },
                                   created_at: 1.hour.ago)
  end

  it 'shows all (visible) events in the history' do
    visit prior_authority_application_events_path(application)

    doc = Nokogiri::HTML(page.html)
    history = doc.css(
      '.govuk-table__cell'
    ).map { _1.text.strip.gsub(/\s+/, ' ') }

    expect(history).to eq(
      ['1 February 20238:00am', 'N/A', 'Received Received from Provider with changes to data',
       '1 February 20237:00am', 'N/A', 'Received Received from Provider with further information and changes to data',
       '1 February 20236:00am', 'case worker', 'Sent back Sent back to Provider for further information',
       '1 February 20235:00am', 'case worker', 'case worker saved a draft',
       '1 February 20234:00am', 'case worker', 'Granted decision comment',
       '1 February 20233:00am', 'case worker', 'case worker saved a draft ',
       '1 February 20232:00am', 'super visor', 'Self-assigned by super visor manual assignment comment',
       '1 February 20231:00am', 'super visor', 'Unassigned by super visor unassignment comment',
       '1 February 202312:00am', 'case worker', 'Assigned to case worker',
       '31 January 202311:00pm', 'N/A', 'Received']
    )
  end
end
