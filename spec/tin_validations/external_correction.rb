require 'rails_helper'
require 'open-uri'
require 'nokogiri'

RSpec.describe TinValidations::ExternalValidationService do
  let(:valid_abn) { '12345678901' }
  let(:invalid_abn) { '12345' }
  let(:non_existent_abn) { '00000000000' }
  let(:service) { described_class.new(abn) }

  describe '#validate' do
    context 'when ABN is valid and registered' do
      let(:abn) { valid_abn }

      before do
        response = <<-XML
          <response>
            <organisationName>Example Company Pty Ltd</organisationName>
            <stateCode>NSW</stateCode>
            <postcode>2000</postcode>
            <status>Active</status>
            <goodsAndServicesTax>true</goodsAndServicesTax>
          </response>
        XML
        allow(URI).to receive(:open).and_return(StringIO.new(response))
      end

      it 'returns valid business registration details' do
        result = service.validate
        expect(result[:business_registration][:name]).to eq('Example Company Pty Ltd')
        expect(result[:business_registration][:address]).to eq('NSW 2000')
        expect(result[:validity][:valid]).to eq(true)
        expect(result[:validity][:registered]).to eq(true)
      end
    end

    context 'when ABN is invalid' do
      let(:abn) { invalid_abn }

      it 'returns an error' do
        result = service.validate
        expect(result[:valid]).to eq(false)
        expect(result[:errors]).to include('Invalid input')
      end
    end

    context 'when ABN does not exist in the system' do
      let(:abn) { non_existent_abn }

      before do
        allow(URI).to receive(:open).and_raise(OpenURI::HTTPError.new('404 Not Found', nil))
      end

      it 'returns a not registered error' do
        result = service.validate
        expect(result[:validation]).to eq(false)
        expect(result[:error]).to eq('Business is not registered')
      end
    end

    context 'when the API returns an internal server error' do
      let(:abn) { valid_abn }

      before do
        allow(URI).to receive(:open).and_raise(OpenURI::HTTPError.new('500 Internal Server Error', nil))
      end

      it 'returns an API error message' do
        result = service.validate
        expect(result[:validation]).to eq(false)
        expect(result[:error]).to eq('Registration API could not be reached')
      end
    end

    context 'when an unexpected error occurs' do
      let(:abn) { valid_abn }

      before do
        allow(URI).to receive(:open).and_raise(StandardError.new('Unexpected error'))
      end

      it 'returns a generic error message' do
        result = service.validate
        expect(result[:validation]).to eq(false)
        expect(result[:errors]).to include('build_response error: Unexpected error')
      end
    end
  end
end
