# frozen_string_literal: true

require 'rails_helper'

RSpec.describe LaaCrimeFormsCommon::Messages::PriorAuthority::Base do
  subject(:feedback) { described_class.new(claim.data) }

  let(:claim) { build(:claim) }

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
