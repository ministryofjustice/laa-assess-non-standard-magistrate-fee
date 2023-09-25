require 'rails_helper'

RSpec.describe V1::CaseDetails do
  describe '#title' do
    it 'shows correct title' do
      expect(subject.title).to eq('Case details')
    end
  end

  describe '#data' do
    subject = described_class.new(
      {
        main_offence: 'Stole an apple',
        main_offence_date: '2023-01-01',
        assigned_counsel: 'yes',
        unassigned_counsel: 'no',
        agent_instructed: 'yes',
        remitted_to_magistrate: 'yes',
        remitted_to_magistrate_date: '2023-02-01'
      }
    )

    it 'shows correct table data' do
      expect(subject.data).to eq([
                                   { title: 'Main offence name', value: 'Stole an apple' },
                                   { title: 'Main offence date', value: '01 January 2023' },
                                   { title: 'Assigned counsel', value: 'Yes' },
                                   { title: 'Unassigned counsel', value: 'No' },
                                   { title: 'Instructed agent', value: 'Yes' },
                                   { title: "Case remitted from Crown Court to magistrates' court", value: 'Yes' },
                                   { title: 'Remittal date', value: '01 February 2023' },
                                 ])
    end

    context 'No remittal' do
      it 'shows correct table data' do
        expect(subject.data).to eq([
                                     { title: 'Main offence name', value: 'Stole an apple' },
                                     { title: 'Main offence date', value: '01 January 2023' },
                                     { title: 'Assigned counsel', value: 'Yes' },
                                     { title: 'Unassigned counsel', value: 'No' },
                                     { title: 'Instructed agent', value: 'Yes' },
                                     { title: "Case remitted from Crown Court to magistrates' court", value: 'No' },
                                   ])
      end
    end
  end
end
