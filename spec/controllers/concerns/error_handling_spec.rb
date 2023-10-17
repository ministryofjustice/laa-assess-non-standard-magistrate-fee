require 'rails_helper'

RSpec.describe HealthcheckController, type: :controller do
  let(:error_class) { Class.new(StandardError) }
  let(:build_args) { nil }

  before do
    allow(controller).to receive(:render).and_raise(error_class)
    allow(ENV).to(receive(:fetch)) { nil }
    allow(ENV).to(receive(:fetch)).with('RAILS_ENV', nil).and_return(rails_env)
    allow(ENV).to(receive(:fetch)).with('SENTRY_DSN', nil).and_return(sentry_dsn)
  end

  context 'any other error class' do
    let(:sentry_dsn) { nil }
    let(:rails_env) { 'development' }

    context 'non production RAILS_ENV' do
      it 'raises the error' do
        expect { get :ping }.to raise_error(error_class)
      end
    end

    context 'production RAILS_ENV' do
      let(:rails_env) { 'production' }

      context 'when SENTRY_DSN is set' do
        let(:sentry_dsn) { 'http://example.com' }

        it 'logs the error' do
          expect(Rails.logger).to receive(:error)
          expect(Sentry).to receive(:capture_exception)

          get :ping
        end
      end

      context 'when SENTRY_DSN is not set' do
        it 'does not logs the error' do
          expect(Rails.logger).to receive(:error)
          expect(Sentry).not_to receive(:capture_exception)

          get :ping
        end
      end
    end
  end
end
