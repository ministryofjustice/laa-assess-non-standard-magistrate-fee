# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PriorAuthority::FeedbackMessages::FeedbackBase do
  subject(:feedback) { described_class.new(application) }

  let(:application) { build(:prior_authority_application) }

  describe '#template' do
    it 'throws a not implemented exception' do
      expect { subject.template }.to raise_error(NotImplementedError)
    end
  end

  describe '#contents' do
    it 'throws a not implemented exception' do
      expect { subject.contents }.to raise_error(NotImplementedError)
    end
  end
end
