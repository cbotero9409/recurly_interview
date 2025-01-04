require 'rails_helper'

describe 'Basic Validation', type: :request do
  let(:valid_params_au) { { country: 'AU', number: '10120000004' } }
  let(:valid_params_ca) { { country: 'CA', number: '123456789RT0001' } }
  let(:valid_params_in) { { country: 'IN', number: '22BCDEF1G2FH1Z5' } }

  let(:invalid_format_params) do
    [
      { country: 'AU', number: 1012004 },
      { country: 'AU', number: '1012000a004' },
      { country: 'AU', number: '10120$000' },
      { country: 'AU', number: '1012000045634563450' },
      { country: 'CA', number: '123456789RT01' },
      { country: 'CA', number: '12345' },
      { country: 'IN', number: 'AABCDEF1G2FH1Z5' },
      { country: 'IN', number: '2234DEF1G2FH1ZA' }
    ]
  end

  let(:invalid_inputs_params) do
    [
      { country: 'CO', number: 1012004 },
      { country: 'AU', number: '' }
    ]
  end

  # Helper to check common expectations
  def expect_valid_response(response_body, tin_type, formatted_tin)
    expect(response_body['valid']).to be true
    expect(response_body['tin_type']).to eql(tin_type)
    expect(response_body['formatted_tin']).to eql(formatted_tin)
  end

  # Valid Tests
  it 'returns valid true, tin_type, and the formatted number for valid inputs' do
    # AU tests
    post '/api/v1/tin_validations/basic', params: valid_params_au
    expect_valid_response(JSON.parse(response.body), 'au_abn', '10 120 000 004')

    post '/api/v1/tin_validations/basic', params: { country: 'AU', number: '10 12000 0004' }
    expect_valid_response(JSON.parse(response.body), 'au_abn', '10 120 000 004')

    post '/api/v1/tin_validations/basic', params: { country: 'AU', number: '      101200000    ' }
    expect_valid_response(JSON.parse(response.body), 'au_acn', '101 200 000')

    post '/api/v1/tin_validations/basic', params: { country: 'AU', number: '101200000' }
    expect_valid_response(JSON.parse(response.body), 'au_acn', '101 200 000')

    # CA tests
    post '/api/v1/tin_validations/basic', params: valid_params_ca
    expect_valid_response(JSON.parse(response.body), 'ca_gst', '123456789RT0001')

    post '/api/v1/tin_validations/basic', params: { country: 'CA', number: '123456789' }
    expect_valid_response(JSON.parse(response.body), 'ca_gst', '123456789RT0001')

    # IN tests
    post '/api/v1/tin_validations/basic', params: valid_params_in
    expect_valid_response(JSON.parse(response.body), 'in_gst', '22BCDEF1G2FH1Z5')
  end

  # Invalid Tests - Invalid format number for country
  describe 'Invalid format number input' do
    it 'returns valid false and the appropriate error message' do
      invalid_format_params.each do |params|
        post '/api/v1/tin_validations/basic', params: params
        expect(JSON.parse(response.body)['valid']).to be false
        expect(JSON.parse(response.body)['errors'].first).to eql('Invalid format number input')
      end
    end
  end

  # Invalid Inputs
  describe 'Invalid inputs' do
    it 'returns valid false and the error: Invalid inputs' do
      invalid_inputs_params.each do |params|
        post '/api/v1/tin_validations/basic', params: params
        expect(JSON.parse(response.body)['valid']).to be false
        expect(JSON.parse(response.body)['errors'].first).to eql('Invalid inputs')
      end
    end
  end
end
