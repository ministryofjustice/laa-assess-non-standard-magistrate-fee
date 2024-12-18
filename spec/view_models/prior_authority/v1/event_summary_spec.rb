require 'rails_helper'

RSpec.describe PriorAuthority::V1::EventSummary do
  describe '#heading' do
    subject(:summary) { described_class.new(event:) }

    context 'when event type is not recognised'
    let(:event) { build(:event, :nsm_send_back) }

    it 'raises an error' do
      expect { summary.heading }.to raise_error(
        "Prior Authority event summaries don't know how to display events of type Nsm::Event::SendBack"
      )
    end
  end
end
