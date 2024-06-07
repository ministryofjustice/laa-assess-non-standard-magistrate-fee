require 'rails_helper'

RSpec.describe 'Decide an application', :stub_oauth_token do
  let(:caseworker) { create(:caseworker) }
  let(:application) { create(:prior_authority_application, state: 'submitted') }

  before do
    sign_in caseworker
    create(:assignment, submission: application, user: caseworker)
    visit '/'
    click_on 'Accept analytics cookies'
    visit prior_authority_application_path(application)
    click_on 'Make a decision'
  end

  context 'when I make a decision' do
    before do
      choose 'Rejected'
      fill_in 'Provide detailed reasons for rejecting this application', with: 'The wrong form was used'
    end

    it 'triggers a notification' do
      expect { click_on 'Submit decision' }.to have_enqueued_job(NotifyAppStore)
    end

    context 'once the decision has been processed' do
      before do
        click_on 'Submit decision'
      end

      it 'shows my decision' do
        expect(page).to have_content 'Decision sent'
        expect(page).to have_content 'LAA decision Rejected'
        expect(page).to have_content "Comments\nThe wrong form was used"
      end

      it 'removes the edit buttons from the application page' do
        click_on 'Return to the application'
        expect(page).to have_no_content 'Make a decision'
      end

      it 'prevents duplicate submission' do
        visit new_prior_authority_application_decision_path(application)
        click_on 'Submit decision'
        expect(page).to have_content 'This application has already been assessed'
      end
    end
  end

  it 'requires me to choose an option' do
    click_on 'Submit decision'
    expect(page).to have_content 'Choose the outcome of your assessment'
  end

  it 'requires an explanation for rejections' do
    choose 'Rejected'
    click_on 'Submit decision'
    expect(page).to have_content 'Enter a reason for rejecting this application'
  end

  it 'explanation is optional for part grants' do
    choose 'Part granted'
    click_on 'Submit decision'
    expect(page).to have_no_content 'Enter a reason for'
  end

  it 'does not allow part grants if no adjustments mae' do
    choose 'Part granted'
    click_on 'Submit decision'
    expect(page).to have_content(
      'You can only part-grant an application if you have made adjustments to provider costs. ' \
      'You can either grant it without any cost adjustments, or make cost adjustments and part-grant it.'
    )
  end

  it 'lets me save my answers and return later' do
    choose 'Rejected'
    fill_in 'Provide detailed reasons for rejecting this application', with: 'The wrong form was used'
    click_on 'Save and come back later'
    visit new_prior_authority_application_decision_path(application)
    expect(page).to have_checked_field('Rejected')
    expect(page).to have_field('Provide detailed reasons for rejecting this application',
                               with: 'The wrong form was used')
  end
end
