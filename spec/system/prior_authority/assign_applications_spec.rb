require 'rails_helper'

RSpec.describe 'Assign applications' do
  let(:caseworker) { create(:caseworker) }

  before do
    sign_in caseworker
    visit '/'
    click_on 'Accept analytics cookies'
    visit prior_authority_root_path
    application
  end

  context 'when there is an application' do
    let(:application) { create(:prior_authority_application, state: 'submitted') }

    it 'lets me assign the application to myself automatically' do
      click_on 'Assess next application'
      expect(application.reload.assignments.first.user).to eq caseworker
      expect(application.events.first).to be_an Event::Assignment
      expect(application.state).to eq 'submitted'
      expect(page).to have_current_path prior_authority_application_path(application)
    end

    context 'when I click to add the application to my list' do
      before do
        visit prior_authority_application_path(application)
        click_on 'Add to my list'
      end

      it 'lets me assign the application to myself manually' do
        fill_in 'Explain your decision', with: 'It looks interesting'
        click_on 'Yes, add to my list'
        expect(application.reload.assignments.first.user).to eq caseworker
        expect(application.events.first).to be_an Event::Assignment
        expect(application.state).to eq 'submitted'
        expect(page).to have_current_path prior_authority_application_path(application)
      end

      it 'requires me to enter an explanation' do
        click_on 'Yes, add to my list'
        expect(page).to have_content 'Explain why you are adding this application to your list'
      end
    end

    it 'prevents me from unassigning it' do
      visit new_prior_authority_application_unassignment_path(application)
      fill_in 'Explain your decision', with: 'It looks interesting'
      click_on 'Yes, remove from list'
      expect(page).to have_content 'This application is not on a list so cannot be removed from one'
    end

    context 'when the application is assigned to someone' do
      let(:someone_else) { create(:caseworker) }

      before do
        create(:assignment, user: someone_else, submission: application)
      end

      context "when I click to remove the application from the user's list" do
        before do
          visit prior_authority_application_path(application)
          click_on 'Remove from list'
        end

        it 'lets me assign the application to myself manually' do
          fill_in 'Explain your decision', with: 'They went on holiday'
          click_on 'Yes, remove from list'
          expect(application.reload.assignments).to be_empty
          expect(application.events.last).to be_an Event::Unassignment
          expect(application.state).to eq 'submitted'
          expect(page).to have_current_path prior_authority_application_path(application)
        end

        it 'requires me to enter an explanation' do
          click_on 'Yes, remove from list'
          expect(page).to have_content 'Explain why you are removing this application from the list'
        end
      end

      it 'prevents me from assigning it to me' do
        visit new_prior_authority_application_manual_assignment_path(application)
        fill_in 'Explain your decision', with: 'It looks interesting'
        click_on 'Yes, add to my list'
        expect(page).to have_content 'This application is already assigned to a caseworker'
      end
    end
  end

  context 'when there is no application' do
    let(:application) { nil }

    it 'shows me an explanation' do
      click_on 'Assess next application'
      expect(page).to have_content 'There are no applications waiting to be allocated'
    end
  end
end
