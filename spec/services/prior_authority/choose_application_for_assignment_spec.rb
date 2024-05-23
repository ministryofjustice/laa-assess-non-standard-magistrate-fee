require 'rails_helper'

RSpec.describe PriorAuthority::ChooseApplicationForAssignment do
  let(:user) { create(:caseworker) }

  context 'when there is an older and a newer application' do
    let(:newer_application) { create(:prior_authority_application, app_store_updated_at: 1.day.ago) }
    let(:older_application) { create(:prior_authority_application, app_store_updated_at: 2.days.ago) }

    before do
      newer_application && older_application
    end

    it 'prefers earlier submisions' do
      expect(described_class.call(user)).to eq older_application
    end
  end

  context 'when the newer application is a central criminal court case' do
    let(:central_court_application) do
      create(:prior_authority_application,
             created_at: 1.day.ago,
                    data: build(:prior_authority_data, court_type: 'central_criminal_court'))
    end

    let(:non_central_court_application) do
      create(:prior_authority_application,
             created_at: 2.days.ago,
                    data: build(:prior_authority_data, court_type: 'other'))
    end

    before do
      central_court_application && non_central_court_application
    end

    it 'prefers the central criminal court case' do
      expect(described_class.call(user)).to eq central_court_application
    end
  end

  context 'when the newer application is a pathology case' do
    let(:pathology_application) do
      create(:prior_authority_application,
             created_at: 1.day.ago,
                    data: build(:prior_authority_data, service_type: 'pathologist_report'))
    end

    let(:non_pathology_application) do
      create(:prior_authority_application,
             created_at: 2.days.ago,
                    data: build(:prior_authority_data, service_type: 'other'))
    end

    before do
      pathology_application && non_pathology_application
    end

    it 'prefers the pathology case' do
      expect(described_class.call(user)).to eq pathology_application
    end
  end

  context 'when there is a pathology case and a central court case' do
    let(:pathology_application) do
      create(:prior_authority_application,
             created_at: 1.day.ago,
                    data: build(:prior_authority_data, service_type: 'pathologist_report'))
    end

    let(:central_court_application) do
      create(:prior_authority_application,
             created_at: 2.days.ago,
                    data: build(:prior_authority_data, court_type: 'central_criminal_court'))
    end

    before do
      pathology_application && central_court_application
    end

    it 'prefers the central criminal court case' do
      expect(described_class.call(user)).to eq central_court_application
    end
  end
end
