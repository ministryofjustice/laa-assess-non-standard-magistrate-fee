require 'rails_helper'

describe 'fixes:', type: :task do
  before do
    Rails.application.load_tasks if Rake::Task.tasks.empty?
  end

  describe 'update_contact_email' do
    subject(:run) do
      Rake::Task['fixes:update_contact_email'].execute(arguments)
    end

    let(:arguments) { Rake::TaskArguments.new [:id, :new_contact_email], [submission.id, 'correct@email.address'] }
    let(:solicitor) { { 'contact_email' => 'wrong@email.address' } }

    before { allow($stdin).to receive_message_chain(:gets, :strip).and_return('y') }

    context 'with a claim submission' do
      let(:submission) { create(:claim, solicitor:) }

      it 'amends contact email' do
        expect { run }.to change { submission.reload.data['solicitor']['contact_email'] }
          .from('wrong@email.address')
          .to('correct@email.address')
      end
    end

    context 'with a prior authority application submission' do
      let(:submission) { create(:prior_authority_application, data: build(:prior_authority_data, solicitor:)) }

      it 'amends contact email' do
        expect { run }.to change { submission.reload.data['solicitor']['contact_email'] }
          .from('wrong@email.address')
          .to('correct@email.address')
      end
    end

    context 'when submission not found' do
      let(:arguments) { Rake::TaskArguments.new [:id, :new_contact_email], ['non-existent-uuid', 'correct@email.address'] }

      it 'raises not found error' do
        expect { run }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe 'fix_corrupt_versions' do
    let(:affected_submission) { create(:prior_authority_application, id: '84fabfe2-844f-4bbe-8460-1be4a18912e3', current_version: 3) }
    let(:unaffected_submission) { create(:prior_authority_application, current_version: 3)}

    before do
      affected_submission
      unaffected_submission
      Rails.application.load_tasks if Rake::Task.tasks.empty?
    end

    after do
      Rake::Task["fixes:fix_corrupt_versions"].reenable
    end

    it 'does not decrement unaffected submission' do
      Rake::Task["fixes:fix_corrupt_versions"].execute
      expect { unaffected_submission.current_version }.to eq(3)
    end

    it 'does decrement affected submission' do
      Rake::Task["fixes:fix_corrupt_versions"].execute
      expect { affected_submission.current_version }.to eq(2)
    end
  end
end
