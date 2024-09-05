require 'rails_helper'

RSpec.describe PriorAuthority::ChooseApplicationForAssignment do
  let(:user) { create(:caseworker) }

  # Priority order should be as follows in descending order of importance:
  # A Prefer applications submitted on the earliest day
  # B Prefer those in Central Criminal Court (court type)
  # C Prefer Pathologist reports (service type) relating to post mortem
  # D Prefer applications submitted at the earliest time of day

  # For example a central criminal court case submitted on day 2 is lower priority than
  # a 'normal' case submitted on day 1, because rule A is more important than rule B.

  let(:a_date) { 1.day.ago }

  context 'when there is an older and a newer application (A)' do
    let(:newer_application) { create(:prior_authority_application, app_store_updated_at: 1.day.ago) }
    let(:older_application) { create(:prior_authority_application, app_store_updated_at: 2.days.ago) }

    before do
      newer_application && older_application
    end

    it 'prefers earlier submisions' do
      expect(described_class.call(user)).to eq older_application
    end
  end

  context 'with two applications on same day where one is a central criminal court case (B)' do
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

  context 'with two applications on different day where the later one is a central criminal court case (A vs B)' do
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

  context 'with two central criminal court cases on the same day where one is older in time (D)' do
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

  context 'with central criminal court case and "normal" case on same day but normal is a minute older (B vs D)' do
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

  context 'with two applications on same day where one is a post mortem pathologist report (C)' do
    let(:pathology_application) do
      create(:prior_authority_application,
             app_store_updated_at: a_date,
             data: build(:prior_authority_data, service_type: 'pathologist_report', quotes: [{ related_to_post_mortem: true }]))
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

  context 'with two applications on different day where one is a post mortem pathologist reports (A vs C)' do
    let(:pathology_application) do
      create(:prior_authority_application,
             app_store_updated_at: 1.day.ago,
             data: build(:prior_authority_data, service_type: 'pathologist_report', quotes: [{ related_to_post_mortem: true }]))
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

  context 'with a pathology case and a central court case on the same day (B vs C)' do
    let(:pathology_application) do
      create(:prior_authority_application,
             app_store_updated_at: a_date,
             data: build(:prior_authority_data, service_type: 'pathologist_report', quotes: [{ related_to_post_mortem: true }]))
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

  context 'with a pathology case, a central court case and older "normal" case (A vs B vs C))' do
    let(:pathology_application) do
      create(:prior_authority_application,
             app_store_updated_at: a_date,
             data: build(:prior_authority_data, service_type: 'pathologist_report', quotes: [{ related_to_post_mortem: true }]))
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

  context 'with two pathologist reports, only one of which is related to post mortem but the other is older (C vs D)' do
    let(:post_mortem) do
      create(:prior_authority_application,
             app_store_updated_at: 1.day.ago.beginning_of_day + 10.hours,
             data: build(:prior_authority_data, service_type: 'pathologist_report', quotes: [{ related_to_post_mortem: true }]))
    end

    let(:non_post_mortem) do
      create(:prior_authority_application,
             app_store_updated_at: 1.day.ago.beginning_of_day + 9.hours,
             data: build(:prior_authority_data, service_type: 'pathologist_report', quotes: [{ related_to_post_mortem: false }]))
    end

    before do
      post_mortem && non_post_mortem
    end

    it 'prefers post mortem one' do
      expect(described_class.call(user)).to eq post_mortem
    end
  end
end
