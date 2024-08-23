require 'rails_helper'

RSpec.describe Nsm::V1::DetailsOfClaim do
  describe '#title' do
    it 'shows correct title' do
      expect(subject.title).to eq('Claim summary')
    end
  end

  describe '#rows' do
    subject(:model) do
      described_class.new(
        {
          'ufn' => 'ABC/12345',
          'claim_type' => {
            'value' => 'non_standard_magistrate',
            'en' => 'Non-standard fee - magistrate'
          },
          'rep_order_date' => '2023-02-01',
          'stage_reached' => 'prom',
          'firm_office' => {
            'account_number' => '121234'
          },
        }
      )
    end

    it 'has correct structure' do
      expect(model.rows).to have_key(:title)
      expect(model.rows).to have_key(:data)
    end
  end

  describe '#data' do
    subject(:model) do
      described_class.new(
        {
          'ufn' => 'ABC/12345',
          'claim_type' => {
            'value' => 'non_standard_magistrate',
            'en' => 'Non-standard fee - magistrate'
          },
          'rep_order_date' => '2023-02-01',
          'stage_reached' => 'prom',
          'firm_office' => {
            'account_number' => '121234'
          },
        }
      )
    end

    it 'shows correct table data' do
      expect(model.data).to eq([
                                 { title: 'Unique file number', value: 'ABC/12345' },
                                 { title: 'Type of claim', value: 'Non-standard fee - magistrate' },
                                 { title: 'Representation order date', value: '1 February 2023' },
                                 { title: 'Stage reached', value: 'PROM' },
                                 { title: 'Firm office account number', value: '121234' },
                               ])
    end

    context 'when it is a breach of injunction' do
      subject(:model) do
        described_class.new(
          {
            'ufn' => 'ABC/12345',
            'claim_type' => {
              'value' => 'breach_of_injunction',
              'en' => 'Breach of injunction'
            },
            'cntp_order' => '123456',
            'cntp_date' => '2023-02-01',
            'stage_reached' => 'prog',
            'firm_office' => {
              'account_number' => '121234'
            },
          }
        )
      end

      it 'shows correct table data' do
        expect(model.data).to eq([
                                   { title: 'Unique file number', value: 'ABC/12345' },
                                   { title: 'Type of claim', value: 'Breach of injunction' },
                                   { title: 'CNTP (contempt) number', value: '123456' },
                                   { title: 'Date of CNTP representation order', value: '1 February 2023' },
                                   { title: 'Stage reached', value: 'PROG' },
                                   { title: 'Firm office account number', value: '121234' },
                                 ])
      end
    end
  end
end
