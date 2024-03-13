require 'rails_helper'

RSpec.describe LocationService do
  describe '.inside_m25?' do
    subject { described_class.inside_m25?(input_postcode) }

    let(:os_api_stub) do
      stub_request(:get, "https://api.os.uk/search/names/v1/find?query=#{sent_postcode}&key=TEST_OS_API_KEY").to_return(
        status: 200,
        body: payload.to_json,
        headers: { 'Content-Type' => 'application/json; charset=utf-8' }
      )
    end
    let(:input_postcode) { 'some postcode' }
    let(:sent_postcode) { 'SOMEPOSTCODE' }

    before { os_api_stub }

    context 'when I provide a London postcode' do
      let(:payload) do
        {
          results: [
            {
              'GAZETTEER_ENTRY' => {
                'ID' => sent_postcode,
                'GEOMETRY_X' => 527_614.0,
                'GEOMETRY_Y' => 175_539.0
              }
            }
          ]
        }
      end

      it 'calls the OS API' do
        subject
        expect(os_api_stub).to have_been_requested
      end

      it 'returns true' do
        expect(subject).to be true
      end
    end

    context 'when I provide a non-London postcode' do
      let(:payload) do
        {
          results: [
            {
              'GAZETTEER_ENTRY' => {
                'ID' => sent_postcode,
                'GEOMETRY_X' => 613_702.0,
                'GEOMETRY_Y' => 284_209.0
              }
            }
          ]
        }
      end

      it 'calls the OS API' do
        subject
        expect(os_api_stub).to have_been_requested
      end

      it 'returns false' do
        expect(subject).to be false
      end
    end

    context 'when the API returns 2 results, where right one is outside London' do
      let(:payload) do
        {
          results: [
            {
              'GAZETTEER_ENTRY' => {
                'ID' => sent_postcode,
                'GEOMETRY_X' => 613_702.0, # Outside London coordinates
                'GEOMETRY_Y' => 284_209.0
              }
            },
            {
              'GAZETTEER_ENTRY' => {
                'ID' => 'OTHERPOSTCODE',
                'GEOMETRY_X' => 527_614.0, # Inside London coordinates
                'GEOMETRY_Y' => 175_539.0
              }
            }
          ]
        }
      end

      it 'uses the right one, and returns false' do
        expect(subject).to be false
      end
    end

    context 'when the API returns unexpected format' do
      let(:payload) do
        { error: 'SOmething unexpected' }
      end

      it 'raises an appropriate error' do
        expect { subject }.to raise_error 'OS API returned unexpected format when queried for postcode SOMEPOSTCODE'
      end
    end

    context 'when the API returns no match' do
      let(:payload) do
        {
          results: [
            {
              'GAZETTEER_ENTRY' => {
                'ID' => 'randompostcode',
                'GEOMETRY_X' => 613_702.0,
                'GEOMETRY_Y' => 284_209.0
              }
            }
          ]
        }
      end

      it 'raises an appropriate error' do
        expect { subject }.to raise_error 'OS API returned no matching entry for postcode SOMEPOSTCODE'
      end
    end

    context 'when the API match has no coordinates' do
      let(:payload) do
        {
          results: [
            {
              'GAZETTEER_ENTRY' => {
                'ID' => sent_postcode
              }
            }
          ]
        }
      end

      it 'raises an appropriate error' do
        expect do
          subject
        end.to raise_error 'OS API did not provide coordinates in expected format for postcode SOMEPOSTCODE'
      end
    end
  end
end
