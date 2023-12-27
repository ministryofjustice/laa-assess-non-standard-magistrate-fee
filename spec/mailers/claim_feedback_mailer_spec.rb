# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ClaimFeedbackMailer, type: :mailer do
  let(:feedback_message) { FeedbackMessages::GrantedFeedback.new(claim) }
  let(:claim) { build(:claim) }
  let(:feedback_template) { '80c0dcd2-597b-4c82-8c94-f6e26af71a40' }
  let(:recipient) { 'provider@example.com' }
  let(:laa_case_reference) { 'LAA-FHaMVK' }
  let(:ufn) { '123456/001' }
  let(:main_defendant_name) { 'Tracy Linklater' }
  let(:maat_id) { 'AB12123' }
  let(:claim_total) { nil }
  let(:date) { DateTime.now.strftime('%d %B %Y') }
  let(:feedback_url) { 'tbc' }

  describe '#notify' do
    subject(:mail) { described_class.notify(feedback_message) }

    it 'is a govuk_notify delivery' do
      expect(mail.delivery_method).to be_a(GovukNotifyRails::Delivery)
    end

    it 'sets the recipient from config' do
      expect(mail.to).to eq([recipient])
    end

    it 'sets the template' do
      expect(
        mail.govuk_notify_template
      ).to eq feedback_template
    end

    it 'sets personalisation from args' do
      expect(
        mail.govuk_notify_personalisation
      ).to include(laa_case_reference:, ufn:, main_defendant_name:, maat_id:, claim_total:, date:, feedback_url:)
    end
  end
end
