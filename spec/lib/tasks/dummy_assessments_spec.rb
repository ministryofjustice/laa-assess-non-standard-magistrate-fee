require 'rails_helper'

describe 'dummy_assessments:', type: :task do
  describe 'create' do
    subject { Rake::Task['dummy_assessments:create'] }

    let(:pa_assessor) { instance_double(PriorAuthority::FakeAssess, perform: true) }
    let(:nsm_assessor) { instance_double(Nsm::FakeAssess, perform: true) }

    before do
      Rails.application.load_tasks if Rake::Task.tasks.empty?
      allow(PriorAuthority::FakeAssess).to receive(:new).and_return(pa_assessor)
      allow(Nsm::FakeAssess).to receive(:new).and_return(nsm_assessor)
    end

    after do
      Rake::Task['dummy_assessments:create'].reenable
    end

    context 'when there is a submitted PA application' do
      before do
        create(:prior_authority_application, state: :submitted)
      end

      it 'runs a job' do
        subject.invoke
        expect(pa_assessor).to have_received(:perform)
      end
    end

    context 'when there is a granted PA application' do
      before do
        create(:prior_authority_application, state: :granted)
      end

      it 'does not run a job' do
        subject.invoke
        expect(pa_assessor).not_to have_received(:perform)
      end
    end

    context 'when there are 150 submitted PA applications' do
      before do
        create_list(:prior_authority_application, 150, state: :submitted)
      end

      it 'runs 2 jobs' do
        subject.invoke
        expect(pa_assessor).to have_received(:perform).exactly(2).times
      end
    end

    context 'when there is a submitted NSM claim' do
      before do
        create(:claim, state: :submitted)
      end

      it 'runs a job' do
        subject.invoke
        expect(nsm_assessor).to have_received(:perform)
      end
    end

    context 'when there is a granted NSM claim' do
      before do
        create(:claim, state: :granted)
      end

      it 'does not run a job' do
        subject.invoke
        expect(nsm_assessor).not_to have_received(:perform)
      end
    end

    context 'when there are 150 submitted NSM claims' do
      before do
        create_list(:claim, 150, state: :submitted)
      end

      it 'runs 2 jobs' do
        subject.invoke
        expect(nsm_assessor).to have_received(:perform).exactly(2).times
      end
    end
  end
end
