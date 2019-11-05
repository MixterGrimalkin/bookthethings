require 'rails_helper'

RSpec.describe 'Authentication', type: :request do

  describe 'POST /auth/login' do

    let!(:user) { create(:user) }

    let(:valid_credentials) { {email: user.email, password: user.password}.to_json }
    let(:invalid_credentials) { {email: Faker::Internet.email, password: Faker::Internet.password}.to_json }

    context 'When request is valid' do
      before {
        post '/auth/login', params: valid_credentials, headers: invalid_headers
      }
      it 'returns an authentication token' do
        expect(json['auth_token']).not_to be_nil
      end
    end
    context 'When request is invalid' do
      before {
        post '/auth/login', params: invalid_credentials, headers: invalid_headers
      }
      it 'returns a failure message' do
        expect(json['auth_token']).to be_nil
        expect(json['message']).to match(/Invalid credentials/)
      end
    end

  end

end