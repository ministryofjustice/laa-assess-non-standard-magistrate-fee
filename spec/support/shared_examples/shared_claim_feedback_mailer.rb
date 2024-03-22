# frozen_string_literal: true

RSpec.shared_examples 'creates a feedback mailer' do
  describe '#notify' do
    subject(:mail) { described_class.notify(claim) }

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
      ).to include(*personalisation)
    end
  end
end

RSpec.shared_examples 'creates a prior authority feedback mailer' do
  describe '#notify' do
    subject(:mail) { described_class.notify(application) }

    it 'is a govuk_notify delivery' do
      expect(mail.delivery_method).to be_a(GovukNotifyRails::Delivery)
    end

    it 'sets the recipient to be the solicitors contact email' do
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
      ).to include(*personalisation)
    end
  end
end
