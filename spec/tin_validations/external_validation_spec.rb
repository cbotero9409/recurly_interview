require 'rails_helper'

describe 'External Validation', type: :request do
  describe 'Tests without errors' do
    # Valid Test
    it 'returns status 200, a hash with business information and registered true' do
      post '/api/v1/tin_validations/external', params: { abn: 10120000004 }
      expect(response.status).to eq(200)
      body = JSON.parse(response.body)
      business_registration = body['business_registration']
      validity = body['validity']
      expect(business_registration['number']).to eql('10120000004')
      expect(business_registration['name']).to eql('Example Company Pty Ltd')
      expect(business_registration['address']).to eql('NSW 2000')
      expect(validity['valid']).to be true
      expect(validity['registered']).to be true
    end

    # Invalid Test (not registered)
    it 'returns status 200, a hash with business information and registered false' do
      post '/api/v1/tin_validations/external', params: { abn: 10000000000 }
      expect(response.status).to eq(200)
      body = JSON.parse(response.body)
      business_registration = body['business_registration']
      validity = body['validity']
      expect(business_registration['number']).to eql('10000000000')
      expect(business_registration['name']).to eql('Example Company Pty Ltd 2')
      expect(business_registration['address']).to eql('NSW 2001')
      expect(validity['valid']).to be true
      expect(validity['registered']).to be false
    end
  end
  
  # Test with errors (HTTP status: 404 or 500)
  describe 'Validation errors' do
    it "returns status 200, validation: false, error: 'Bussiness is not registered' and server_status: '404 Not Found'" do
      post '/api/v1/tin_validations/external', params: { abn: 51824753556 }
      expect(JSON.parse(response.body)['validation']).to be false
      expect(JSON.parse(response.body)['error']).to eql('Bussiness is not registered')
      expect(JSON.parse(response.body)['server_status']).to eql('404 Not Found')
    end

    it "returns status 200, validation: false, error: 'Registration API could not be reached' and server_status: '500 Internal Server Error'" do
      post '/api/v1/tin_validations/external', params: { abn: 53004085616 }
      expect(JSON.parse(response.body)['validation']).to be false
      expect(JSON.parse(response.body)['error']).to eql('Registration API could not be reached')
      expect(JSON.parse(response.body)['server_status']).to eql('500 Internal Server Error')
    end
  end 
end