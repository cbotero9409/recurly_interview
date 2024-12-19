require 'rails_helper'

describe 'Basic Validation', type: :request do
  # Valid Tests
  it 'returns valid true. tin_type and the formatted number' do
    post '/api/v1/tin_validations/basic', params: { country: 'AU', number: 10120000004}
    expect(JSON.parse(response.body)['valid']).to be true
    expect(JSON.parse(response.body)['tin_type']).to eql('au_abn')
    expect(JSON.parse(response.body)['formatted_tin']).to eql('10 120 000 004')

    post '/api/v1/tin_validations/basic', params: { country: 'AU', number: '10 12000 0004'}
    expect(JSON.parse(response.body)['valid']).to be true
    expect(JSON.parse(response.body)['tin_type']).to eql('au_abn')
    expect(JSON.parse(response.body)['formatted_tin']).to eql('10 120 000 004')

    post '/api/v1/tin_validations/basic', params: { country: 'AU', number: '      101200000    '}
    expect(JSON.parse(response.body)['valid']).to be true
    expect(JSON.parse(response.body)['tin_type']).to eql('au_acn')
    expect(JSON.parse(response.body)['formatted_tin']).to eql('101 200 000')

    post '/api/v1/tin_validations/basic', params: { country: 'AU', number: '101200000'}
    expect(JSON.parse(response.body)['valid']).to be true
    expect(JSON.parse(response.body)['tin_type']).to eql('au_acn')
    expect(JSON.parse(response.body)['formatted_tin']).to eql('101 200 000')

    post '/api/v1/tin_validations/basic', params: { country: 'CA', number: '123456789RT0001'}
    expect(JSON.parse(response.body)['valid']).to be true
    expect(JSON.parse(response.body)['tin_type']).to eql('ca_gst')
    expect(JSON.parse(response.body)['formatted_tin']).to eql('123456789RT0001')

    post '/api/v1/tin_validations/basic', params: { country: 'CA', number: '123456789'}
    expect(JSON.parse(response.body)['valid']).to be true
    expect(JSON.parse(response.body)['tin_type']).to eql('ca_gst')
    expect(JSON.parse(response.body)['formatted_tin']).to eql('123456789RT0001')

    post '/api/v1/tin_validations/basic', params: { country: 'IN', number: '22BCDEF1G2FH1Z5'}
    expect(JSON.parse(response.body)['valid']).to be true
    expect(JSON.parse(response.body)['tin_type']).to eql('in_gst')
    expect(JSON.parse(response.body)['formatted_tin']).to eql('22BCDEF1G2FH1Z5')
  end

  # Invalid Tests
  describe 'Invalid tests' do
    # Invalid format number for country
    it 'returns valid false and the error: Invalid format number input' do
      post '/api/v1/tin_validations/basic', params: { country: 'AU', number: 1012004}
      expect(JSON.parse(response.body)['valid']).to be false
      expect(JSON.parse(response.body)['errors'].first).to eql('Invalid format number input')

      post '/api/v1/tin_validations/basic', params: { country: 'AU', number: '1012000a004'}
      expect(JSON.parse(response.body)['valid']).to be false
      expect(JSON.parse(response.body)['errors'].first).to eql('Invalid format number input')

      post '/api/v1/tin_validations/basic', params: { country: 'AU', number: '10120$000'}
      expect(JSON.parse(response.body)['valid']).to be false
      expect(JSON.parse(response.body)['errors'].first).to eql('Invalid format number input')

      post '/api/v1/tin_validations/basic', params: { country: 'AU', number: '1012000045634563450'}
      expect(JSON.parse(response.body)['valid']).to be false
      expect(JSON.parse(response.body)['errors'].first).to eql('Invalid format number input')

      post '/api/v1/tin_validations/basic', params: { country: 'CA', number: '123456789RT01'}
      expect(JSON.parse(response.body)['valid']).to be false
      expect(JSON.parse(response.body)['errors'].first).to eql('Invalid format number input')

      post '/api/v1/tin_validations/basic', params: { country: 'CA', number: '12345'}
      expect(JSON.parse(response.body)['valid']).to be false
      expect(JSON.parse(response.body)['errors'].first).to eql('Invalid format number input')

      post '/api/v1/tin_validations/basic', params: { country: 'IN', number: 'AABCDEF1G2FH1Z5'}
      expect(JSON.parse(response.body)['valid']).to be false
      expect(JSON.parse(response.body)['errors'].first).to eql('Invalid format number input')

      post '/api/v1/tin_validations/basic', params: { country: 'IN', number: '2234DEF1G2FH1ZA'}
      expect(JSON.parse(response.body)['valid']).to be false
      expect(JSON.parse(response.body)['errors'].first).to eql('Invalid format number input')
    end

    # Invalid inputs
    it 'returns valid false and the error: Invalid inputs' do
      post '/api/v1/tin_validations/basic', params: { country: 'CO', number: 1012004}
      expect(JSON.parse(response.body)['valid']).to be false
      expect(JSON.parse(response.body)['errors'].first).to eql('Invalid inputs')

      post '/api/v1/tin_validations/basic', params: { country: 'AU', number: ''}
      expect(JSON.parse(response.body)['valid']).to be false
      expect(JSON.parse(response.body)['errors'].first).to eql('Invalid inputs')
    end
  end 
end