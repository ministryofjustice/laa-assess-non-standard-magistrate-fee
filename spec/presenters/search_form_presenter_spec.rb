require 'rails_helper'

RSpec.describe SearchFormPresenter do
  subject { described_class.new(service) }

  let(:service) { 'crm7' }

  context 'cmr7' do
    describe '.result_headers' do
      it 'adds risk column to headers' do
        expect(subject.result_headers).to eq %i[laa_reference
                                                firm_name client_name caseworker
                                                last_updated risk status_with_assignment]
      end
    end

    describe '.show_risk_filer' do
      it 'returns true' do
        expect(subject.show_risk_filter?).to be true
      end
    end
  end

  context 'crm4' do
    let(:service) { 'crm4' }

    describe '.result_headers' do
      it 'does not add risk column to headers' do
        expect(subject.result_headers).to eq %i[laa_reference
                                                firm_name client_name caseworker
                                                last_updated status_with_assignment]
      end
    end

    describe '.show_risk_filer' do
      it 'returns true' do
        expect(subject.show_risk_filter?).to be false
      end
    end
  end

  context 'analytics' do
    let(:service) { 'analytics' }

    describe '.result_headers' do
      it 'adds risk column to headers' do
        expect(subject.result_headers).to eq %i[laa_reference
                                                firm_name client_name caseworker
                                                last_updated risk status_with_assignment]
      end
    end

    describe '.show_risk_filer' do
      it 'returns true' do
        expect(subject.show_risk_filter?).to be true
      end
    end
  end
end
