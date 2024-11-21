require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe '#current_application' do
    it 'raises an error' do
      expect { helper.current_application }.to raise_error('implement this action, in subclasses')
    end
  end

  describe '#title' do
    let(:title) { helper.content_for(:page_title) }

    context 'when using default layout' do
      before do
        helper.title(value)
      end

      context 'for a blank value' do
        let(:value) { '' }

        it { expect(title).to eq('Assess a crime form - GOV.UK') }
      end

      context 'for a provided value' do
        let(:value) { 'Test page' }

        it { expect(title).to eq('Test page - Assess a crime form - GOV.UK') }
      end
    end

    context 'when using a known layout' do
      let(:lookup_context) { 'context' }
      let(:value) { 'Test page' }

      before do
        allow(helper).to receive(:lookup_context).and_return(lookup_context)
      end

      context 'when current_layout is nsm' do
        before do
          allow(helper).to receive_message_chain(:controller, :send).with(:_layout, lookup_context, [])
                                                                    .and_return('nsm')
          helper.title(value)
        end

        it { expect(title).to eq('Test page - Assess a non-standard magistrates’ court payment - GOV.UK') }
      end

      context 'when current_layout is oa' do
        before do
          allow(helper).to receive_message_chain(:controller, :send).with(:_layout, lookup_context, [])
                                                                    .and_return('prior_authority')
          helper.title(value)
        end

        it { expect(title).to eq('Test page - Assess prior authority to incur disbursements - GOV.UK') }
      end
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

    context 'when period is not nil and short style specified' do
      it 'formats the value in hours and minutes' do
        expect(helper.format_period(62)).to eq('1 hour 2 minutes')
        expect(helper.format_period(1)).to eq('0 hours 1 minute')
        expect(helper.format_period(120)).to eq('2 hours 0 minutes')
      end
    end

    context 'when period is not nil and long style specified' do
      it 'formats the value in hours and minutes' do
        expect(helper.format_period(62, style: :long_html)).to eq('1 hour<br><nobr>2 minutes</nobr>')
        expect(helper.format_period(1, style: :long_html)).to eq('0 hours<br><nobr>1 minute</nobr>')
        expect(helper.format_period(120, style: :long_html)).to eq('2 hours<br><nobr>0 minutes</nobr>')
      end
    end

    context 'when period is not nil and line style specified' do
      it 'formats the value in hours and minutes' do
        expect(helper.format_period(62, style: :line_html)).to eq('<nobr>1 hour 2 minutes</nobr>')
        expect(helper.format_period(1, style: :line_html)).to eq('<nobr>0 hours 1 minute</nobr>')
        expect(helper.format_period(120, style: :line_html)).to eq('<nobr>2 hours 0 minutes</nobr>')
      end
    end

    context 'when period is not nil and minimal style specified' do
      it 'formats the value in hours and minutes' do
        expect(helper.format_period(62, style: :minimal_html)).to eq(
          '1<span class="govuk-visually-hidden"> hour</span>:02<span class="govuk-visually-hidden"> minutes</span>'
        )
        expect(helper.format_period(1, style: :minimal_html)).to eq(
          '0<span class="govuk-visually-hidden"> hours</span>:01<span class="govuk-visually-hidden"> minute</span>'
        )
        expect(helper.format_period(120, style: :minimal_html)).to eq(
          '2<span class="govuk-visually-hidden"> hours</span>:00<span class="govuk-visually-hidden"> minutes</span>'
        )
      end
    end
  end

  describe '#format_in_zone' do
    let(:format) { '%A<br>%d %b %Y<br>%I:%M%P' }

    context 'when date is a string' do
      let(:time) { '2023/10/18 13:08 +0000' }

      context 'with format' do
        it 'converts string to a DateTime and renders format' do
          expect(helper.format_in_zone(time, format:)).to eq(
            'Wednesday<br>18 Oct 2023<br>02:08pm'
          )
        end
      end

      context 'without format' do
        it 'converts string to a DateTime and renders as date' do
          expect(helper.format_in_zone(time)).to eq('18 October 2023')
        end
      end
    end

    context 'when date is a time' do
      let(:time) { DateTime.parse('2023/10/17 13:08 +0000') }

      context 'with format' do
        it 'converts string to a DateTime and renders format' do
          expect(helper.format_in_zone(time, format:)).to eq(
            'Tuesday<br>17 Oct 2023<br>02:08pm'
          )
        end
      end

      context 'without format' do
        it 'converts string to a DateTime and renders as date' do
          expect(helper.format_in_zone(time)).to eq('17 October 2023')
        end
      end
    end

    context 'when date is nil' do
      let(:time) { nil }

      context 'with format' do
        it { expect(helper.format_in_zone(time, format:)).to be_nil }
      end

      context 'without format' do
        it { expect(helper.format_in_zone(time)).to be_nil }
      end
    end
  end

  describe '#govuk_error_summary' do
    context 'when no form object is given' do
      let(:form_object) { nil }

      it 'returns nil' do
        expect(helper.govuk_error_summary(form_object)).to be_nil
      end
    end

    context 'when a form object without errors is given' do
      let(:form_object) { Nsm::MakeDecisionForm.new }

      it 'returns nil' do
        expect(helper.govuk_error_summary(form_object)).to be_nil
      end
    end

    context 'when a form object with errors is given' do
      let(:form_object) { Nsm::MakeDecisionForm.new }
      let(:title) { helper.content_for(:page_title) }

      before do
        helper.title('A page')
        form_object.errors.add(:base, :blank)
      end

      it 'returns the summary' do
        expect(
          helper.govuk_error_summary(form_object)
        ).to eq(
          '<div class="govuk-error-summary" data-module="govuk-error-summary"><div role="alert">' \
          '<h2 class="govuk-error-summary__title">There is a problem on this page</h2>' \
          '<div class="govuk-error-summary__body"><ul class="govuk-list govuk-error-summary__list">' \
          '<li><a data-turbo="false" href="#nsm-make-decision-form-base-field-error">' \
          'can&#39;t be blank</a></li>' \
          '</ul></div></div></div>'
        )
      end

      it 'prepends the page title with an error hint' do
        helper.govuk_error_summary(form_object)
        expect(title).to start_with('Error: A page')
      end
    end
  end

  describe '#gbp_field_value' do
    context 'when it is given a string' do
      let(:value) { 'invalid value' }

      it 'returns the string' do
        expect(helper.gbp_field_value(value)).to eq(value)
      end
    end

    context 'when it is given a number' do
      let(:value) { 1234.5 }

      it 'returns a nice representation of that number as a monetary value' do
        expect(helper.gbp_field_value(value)).to eq('1,234.50')
      end
    end
  end

  describe '#infer_claim_section' do
    let(:claim) { nil }

    before do
      allow(Claim).to receive(:load_from_app_store).and_return(claim)
    end

    it 'returns nothing if there is no relevant param' do
      expect(helper.infer_claim_section).to be_nil
    end

    context 'when there is a claim param' do
      before do
        allow(helper).to receive_messages(params: { claim_id: claim.id }, current_user: user)
      end

      let(:claim) { build :claim }
      let(:user) { create :caseworker }

      it { expect(helper.infer_claim_section).to eq :open }

      context 'when the claim is assessed' do
        let(:claim) do
          build :claim, state: 'granted'
        end

        it { expect(helper.infer_claim_section).to eq :closed }
      end

      context 'when the claim is assigned to current user' do
        before do
          claim.assigned_user_id = user.id
        end

        it { expect(helper.infer_claim_section).to eq :your }
      end
    end
  end
end
