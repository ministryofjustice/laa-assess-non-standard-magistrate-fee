require 'rails_helper'

describe 'dummy_assessments:', type: :task do
  describe 'create' do
    subject { Rake::Task['dummy_assessments:create'] }

    before do
      Rails.application.load_tasks if Rake::Task.tasks.empty?
    end

    after do
      Rake::Task['dummy_assessments:create'].reenable
    end

    context 'when there is a submitted PA application' do
      before do
        create(:prior_authority_application, state: :submitted)
      end

      it 'enqueues a job' do
        expect { subject.invoke }.to have_enqueued_job(PriorAuthority::FakeAssess)
      end
    end

    context 'when there is a granted PA application' do
      before do
        create(:prior_authority_application, state: :granted)
      end

      it 'does not enqueue a job' do
        expect { subject.invoke }.not_to have_enqueued_job(PriorAuthority::FakeAssess)
      end
    end

    context 'when there are 150 submitted PA applications' do
      before do
        create_list(:prior_authority_application, 150, state: :submitted)
      end

      it 'enqueues 2 jobs' do
        expect { subject.invoke }.to have_enqueued_job(PriorAuthority::FakeAssess).exactly(2).times
      end
    end

    context 'when there is a submitted NSM claim' do
      before do
        create(:claim, state: :submitted)
      end

      it 'enqueues a job' do
        expect { subject.invoke }.to have_enqueued_job(Nsm::FakeAssess)
      end
    end

    context 'when there is a granted NSM claim' do
      before do
        create(:claim, state: :granted)
      end

      it 'does not enqueue a job' do
        expect { subject.invoke }.not_to have_enqueued_job(Nsm::FakeAssess)
      end
    end

    context 'when there are 150 submitted NSM claims' do
      before do
        create_list(:claim, 150, state: :submitted)
      end

      it 'enqueues 2 jobs' do
        expect { subject.invoke }.to have_enqueued_job(Nsm::FakeAssess).exactly(2).times
      end
    end
  end
end
