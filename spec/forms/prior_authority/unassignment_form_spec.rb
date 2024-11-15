require 'rails_helper'

RSpec.describe PriorAuthority::UnassignmentForm, :stub_oauth_token do
  subject { described_class.new(params) }

  let(:params) { { application: } }
  let(:caseworker) { create(:caseworker) }

  describe '#caseworker_name' do
    context 'when there is a caseworker' do
      let(:application) { build(:prior_authority_application, assigned_user_id: caseworker.id) }

      it { expect(subject.caseworker_name).to eq(caseworker.display_name) }
    end

    context 'when there is no caseworker' do
      let(:application) { build(:prior_authority_application, assigned_user_id: nil) }

      it { expect(subject.caseworker_name).to be_nil }
    end
  end
end
