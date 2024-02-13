require 'rails_helper'

RSpec.describe 'Feedback' do
  before do
    allow(AppStoreService).to receive(:list).and_return([[], 0])
    sign_in create(:caseworker)
    visit root_path
    click_on 'Feedback'
  end

  it 'lets me submit feedback' do
    page.text
    fill_in 'What is your email address?', with: 'foo@example.com'
    fill_in 'Tell us about your experience of using this service today.', with: 'I was not satisfied'
    choose 'Dissatisfied'
    click_on 'Continue'
    expect(page).to have_content 'Your feedback has been submitted'
    job = ActiveJob::Base.queue_adapter.enqueued_jobs.first
    expect(job[:args][0..2]).to eq ['FeedbackMailer', 'notify', 'deliver_now!']
    params = job[:args][3]['args'][0]
    expect(params['user_email']).to eq 'foo@example.com'
    expect(params['user_rating']).to eq '2'
    expect(params['user_feedback']).to eq 'I was not satisfied'
  end

  it 'forces me to specify a satisfaction level' do
    click_on 'Continue'
    expect(page).to have_content 'Choose a rating'
  end
end
