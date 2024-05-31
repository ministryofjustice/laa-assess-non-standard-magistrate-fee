require 'rails_helper'

RSpec.describe PriorAuthority::ChooseApplicationForAssignment do
  let(:user) { create(:caseworker) }

  # Priority order should be as follows
  # P1 - Oldest Date + Central Criminal Court (court type)
  # P2 - Oldest Date + Pathologist (service type)
  # P3 - Oldest Date
  #

  let(:a_date) { 1.day.ago }

  context 'when there is an older and a newer application (P3)' do
    let(:newer_application) { create(:prior_authority_application, app_store_updated_at: 1.day.ago) }
    let(:older_application) { create(:prior_authority_application, app_store_updated_at: 2.days.ago) }

    before do
      newer_application && older_application
    end

    it 'prefers earlier submisions' do
      expect(described_class.call(user)).to eq older_application
    end
  end

  context 'with two applications on same day where one is a central criminal court case (P1 + P3)' do
    let(:central_court_application) do
      create(:prior_authority_application,
             app_store_updated_at: a_date,
             data: build(:prior_authority_data, court_type: 'central_criminal_court'))
    end

    let(:non_central_court_application) do
      create(:prior_authority_application,
             app_store_updated_at: a_date,
             data: build(:prior_authority_data, court_type: 'other'))
    end

    before do
      central_court_application && non_central_court_application
    end

    it 'prefers the central criminal court case' do
      expect(described_class.call(user)).to eq central_court_application
    end
  end

  context 'with two applications on different day where one is a central criminal court case (P1 + older P3)' do
    let(:central_court_application) do
      create(:prior_authority_application,
             app_store_updated_at: 1.day.ago,
             data: build(:prior_authority_data, court_type: 'central_criminal_court'))
    end

    let(:non_central_court_application) do
      create(:prior_authority_application,
             app_store_updated_at: 2.days.ago,
             data: build(:prior_authority_data, court_type: 'other'))
    end

    before do
      central_court_application && non_central_court_application
    end

    it 'prefers the older non criminal court case' do
      expect(described_class.call(user)).to eq non_central_court_application
    end
  end

  context 'with two central criminal court cases on the same day where one is older in time (P1 + bit older P1)' do
    let(:central_court_application) do
      create(:prior_authority_application,
             app_store_updated_at: a_date,
             data: build(:prior_authority_data, court_type: 'central_criminal_court'))
    end

    let(:older_central_court_application) do
      create(:prior_authority_application,
             app_store_updated_at: a_date - 1.minute,
             data: build(:prior_authority_data, court_type: 'central_criminal_court'))
    end

    before do
      # create older last to avoid false positives resulting from default DB ordering
      central_court_application && older_central_court_application
    end

    it 'prefers the older criminal court case' do
      expect(described_class.call(user)).to eq older_central_court_application
    end
  end

  context 'with central criminal court case and "normal" case on same but normal is only a minute older (P1 + bit older P3)' do
    let(:central_court_application) do
      create(:prior_authority_application,
             app_store_updated_at: a_date,
             data: build(:prior_authority_data, court_type: 'central_criminal_court'))
    end

    let(:non_central_court_application) do
      create(:prior_authority_application,
             app_store_updated_at: a_date - 1.minute,
             data: build(:prior_authority_data, court_type: 'other'))
    end

    before do
      central_court_application && non_central_court_application
    end

    it 'prefers the little newer criminal court case' do
      expect(described_class.call(user)).to eq central_court_application
    end
  end

  context 'with two applications on same day where one is a pathologist report service case (P2 + P3)' do
    let(:pathology_application) do
      create(:prior_authority_application,
             app_store_updated_at: a_date,
             data: build(:prior_authority_data, service_type: 'pathologist_report'))
    end

    let(:non_pathology_application) do
      create(:prior_authority_application,
             app_store_updated_at: a_date,
             data: build(:prior_authority_data, service_type: 'other'))
    end

    before do
      pathology_application && non_pathology_application
    end

    it 'prefers the pathology case' do
      expect(described_class.call(user)).to eq pathology_application
    end
  end

  context 'with two applications on different day where one is a pathologist report service case (P2 + older P3)' do
    let(:pathology_application) do
      create(:prior_authority_application,
             app_store_updated_at: 1.day.ago,
             data: build(:prior_authority_data, service_type: 'pathologist_report'))
    end

    let(:non_pathology_application) do
      create(:prior_authority_application,
             app_store_updated_at: 2.days.ago,
             data: build(:prior_authority_data, service_type: 'other'))
    end

    before do
      pathology_application && non_pathology_application
    end

    it 'prefers the older case' do
      expect(described_class.call(user)).to eq non_pathology_application
    end
  end

  context 'with a pathology case and a central court case on the same day (P1 + P2)' do
    let(:pathology_application) do
      create(:prior_authority_application,
             app_store_updated_at: a_date,
             data: build(:prior_authority_data, service_type: 'pathologist_report'))
    end

    let(:central_court_application) do
      create(:prior_authority_application,
             app_store_updated_at: a_date,
            data: build(:prior_authority_data, court_type: 'central_criminal_court'))
    end

    before do
      pathology_application && central_court_application
    end

    it 'prefers the central criminal court case' do
      expect(described_class.call(user)).to eq central_court_application
    end
  end

  context 'with a pathology case, a central court case and older "normal" case (P1 + P2 + older P3)' do
    let(:pathology_application) do
      create(:prior_authority_application,
             app_store_updated_at: a_date,
             data: build(:prior_authority_data, service_type: 'pathologist_report'))
    end

    let(:central_court_application) do
      create(:prior_authority_application,
             app_store_updated_at: a_date,
            data: build(:prior_authority_data, court_type: 'central_criminal_court'))
    end

    let(:non_special_application) do
      create(:prior_authority_application,
             app_store_updated_at: 2.days.ago,
             data: build(:prior_authority_data, court_type: 'other', service_type: 'other'))
    end

    before do
      pathology_application && central_court_application && non_special_application
    end

    it 'prefers the older case' do
      expect(described_class.call(user)).to eq non_special_application
    end
  end
end
