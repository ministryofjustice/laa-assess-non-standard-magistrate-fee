require 'rails_helper'

RSpec.describe 'Reauthentication' do
  let(:reauthenticate_in) { Rails.configuration.x.auth.reauthenticate_in }
  let(:user) { create(:caseworker) }
  let(:sign_out_all_scopes) { true }

  before do
    allow(Devise).to receive(:sign_out_all_scopes).and_return(sign_out_all_scopes)
    sign_in user
    visit '/nsm/claims/your'
    user.update(last_auth_at:)
    visit current_path
  end

  context 'when the authentication has not expired' do
    let(:last_auth_at) { (reauthenticate_in - 1.second).ago }

    it 'the site can be accessed' do
      expect(page).to have_content 'Your claims'
    end
  end

  context 'when the authentication has expired' do
    let(:last_auth_at) { (reauthenticate_in + 1.second).ago }

    it 'signs the user out' do
      expect(page).to have_no_content 'Your claims'
    end

    it 'shows the notification banner' do
      expect(page).to have_content('For your security, we signed you out')
      expect(page).to have_content('This is because you were signed in for more than 12 hours.')
    end

    context 'when `Devise.sign_out_all_scopes` is false' do
      let(:sign_out_all_scopes) { false }

      it 'signs the user out' do
        expect(page).to have_no_content 'Your claims'
      end

      it 'shows the notification banner' do
        expect(page).to have_content('For your security, we signed you out')
        expect(page).to have_content('This is because you were signed in for more than 12 hours.')
      end
    end
  end
end
