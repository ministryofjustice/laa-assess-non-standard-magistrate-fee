require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe '#current_application' do
    it 'raises an error' do
      expect { helper.current_application }.to raise_error('implement this action, in subclasses')
    end
  end

  describe '#current_page?' do
    before do
      allow(helper).to receive(:request).and_return(double(path: '/your_claims'))
    end

    it 'returns "page" when current page matches argument' do
      expect(helper.current_page?('your_claims')).to eq('page')
    end

    it 'returns nil when current page does not match argument' do
      expect(helper.current_page?('claims')).to be_nil
    end
  end

  describe '#title' do
    let(:title) { helper.content_for(:page_title) }

    before do
      helper.title(value)
    end

    context 'for a blank value' do
      let(:value) { '' }

      it { expect(title).to eq('Review criminal legal aid applications - GOV.UK') }
    end

    context 'for a provided value' do
      let(:value) { 'Test page' }

      it { expect(title).to eq('Test page - Review criminal legal aid applications - GOV.UK') }
    end
  end

  describe '#fallback_title' do
    before do
      allow(helper).to receive_messages(controller_name: 'my_controller', action_name: 'an_action')

      # So we can simulate what would happen on production
      allow(
        Rails.application.config
      ).to receive(:consider_all_requests_local).and_return(false)
    end

    it 'calls #title with a blank value' do
      expect(helper).to receive(:title).with('')
      helper.fallback_title
    end

    context 'when consider_all_requests_local is true' do
      it 'raises an exception' do
        allow(Rails.application.config).to receive(:consider_all_requests_local).and_return(true)
        expect { helper.fallback_title }.to raise_error('page title missing: my_controller#an_action')
      end
    end
  end

  describe '#app_environment' do
    context 'when ENV is set' do
      around do |spec|
        env = ENV.fetch('ENV', nil)
        ENV['ENV'] = 'test'
        spec.run
        ENV['ENV'] = env
      end

      it 'returns based on ENV variable' do
        expect(helper.app_environment).to eq('app-environment-test')
      end
    end

    context 'when ENV is not set' do
      it 'returns based with local' do
        expect(helper.app_environment).to eq('app-environment-local')
      end
    end
  end

  describe '#format_period' do
    context 'when period is nil' do
      it { expect(helper.format_period(nil)).to be_nil }
    end

    context 'when period is not nil' do
      it 'formats the value in hours and minutes' do
        expect(helper.format_period(62)).to eq('1 Hr 2 Mins')
        expect(helper.format_period(1)).to eq('0 Hrs 1 Min')
      end
    end
  end
end
