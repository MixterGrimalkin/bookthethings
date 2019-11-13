require 'rails_helper'

RSpec.describe 'Users API', type: :request do

  let(:existing_user) { create(:user) }

  describe 'POST /signup' do
    before {
      post '/signup', params: params, headers: invalid_headers
    }
    context 'when valid request' do
      let(:params) { attributes_for(:user, password_confirmation: existing_user.password).to_json }
      it 'responds with 201 (created)' do
        expect(response).to have_http_status(201)
      end
      it 'creates a new user' do
        expect(User.count).to eq(2)
      end
      it 'returns success message' do
        expect(json['message']).to match(/Account created successfully/)
      end
      it 'returns an authentication token' do
        expect(json['auth_token']).not_to be_nil
      end
    end
    context 'when email already exists' do
      let(:params) { attributes_for(:user, email: existing_user.email, password_confirmation: existing_user.password).to_json }
      it 'responds with 422 (unprocessable entity)' do
        expect(response.status).to eq(422)
      end
      it 'responds with an error message' do
        expect(response.body).to match(/Email has already been taken/)
      end
    end
    context 'when invalid request' do
      let(:params) { {}.to_json }
      it 'does not create a new user' do
        expect(response).to have_http_status(422)
      end
      it 'returns failure message' do
        expect(json['message']).to match(/Validation failed:/)
        expect(json['message']).to match(/Password can't be blank/)
        expect(json['message']).to match(/Name can't be blank/)
        expect(json['message']).to match(/Email can't be blank/)
        expect(json['message']).to match(/Password digest can't be blank/)
      end
    end
  end


end