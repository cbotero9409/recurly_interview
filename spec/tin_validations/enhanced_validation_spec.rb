require 'rails_helper'

describe 'Enahnced Validation', type: :request do
  describe 'Tests without errors' do
    # Valid Tests
    it 'returns valid true and number' do
      post '/api/v1/tin_validations/enhanced', params: { number: "51 824 753 556" }
      expect(JSON.parse(response.body)['valid']).to be true
      expect(JSON.parse(response.body)['number']).to eql('51824753556')

      post '/api/v1/tin_validations/enhanced', params: { number: 10000000000 }
      expect(JSON.parse(response.body)['valid']).to be true
      expect(JSON.parse(response.body)['number']).to eql('10000000000')

      post '/api/v1/tin_validations/enhanced', params: { number: "1012000 0004 " }
      expect(JSON.parse(response.body)['valid']).to be true
      expect(JSON.parse(response.body)['number']).to eql('10120000004')
    end

    # Invalid Tests
    it 'returns valid false and number' do
      post '/api/v1/tin_validations/enhanced', params: { number: 10120000005 }
      expect(JSON.parse(response.body)['valid']).to be false
      expect(JSON.parse(response.body)['number']).to eql('10120000005')

      post '/api/v1/tin_validations/enhanced', params: { number: "51 824 753 557" }
      expect(JSON.parse(response.body)['valid']).to be false
      expect(JSON.parse(response.body)['number']).to eql('51824753557')
    end
  end
  
  # Test with errors in the inputs (number as an empty string or its length != 11)
  describe 'Invalid inputs' do
    it 'returns valid false and the error: Invalid inputs' do
      post '/api/v1/tin_validations/enhanced', params: { number: 1012004 }
      expect(JSON.parse(response.body)['valid']).to be false
      expect(JSON.parse(response.body)['errors'].first).to eql('Invalid input')

      post '/api/v1/tin_validations/enhanced', params: { number: '' }
      expect(JSON.parse(response.body)['valid']).to be false
      expect(JSON.parse(response.body)['errors'].first).to eql('Invalid input')
    end
  end 
end