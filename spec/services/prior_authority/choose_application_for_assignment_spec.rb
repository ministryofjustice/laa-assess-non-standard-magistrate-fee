require 'rails_helper'

RSpec.describe PriorAuthority::ChooseApplicationForAssignment do
  let(:user) { create(:caseworker) }

  it 'prefers central criminal court cases' do
    central = create(:prior_authority_application,
                     data: build(:prior_authority_data, court_type: 'central_criminal_court'))
    create(:prior_authority_application, data: build(:prior_authority_data, court_type: 'other'))
    expect(described_class.call(user)).to eq central
  end

  it 'prefers pathology court cases' do
    create(:prior_authority_application, data: build(:prior_authority_data, service_type: 'other'))
    pathology = create(:prior_authority_application, data: build(:prior_authority_data, service_type: 'pathologist'))
    expect(described_class.call(user)).to eq pathology
  end

  it 'prefers central criminal to pathology court cases' do
    central = create(:prior_authority_application,
                     data: build(:prior_authority_data, service_type: 'other', court_type: 'central_criminal_court'))
    create(:prior_authority_application,
           data: build(:prior_authority_data, service_type: 'pathologist', court_type: 'other'))
    expect(described_class.call(user)).to eq central
  end

  it 'prefers earlier submisions' do
    create(:prior_authority_application, created_at: 1.day.ago)
    prior = create(:prior_authority_application, created_at: 2.days.ago)
    expect(described_class.call(user)).to eq prior
  end
end
