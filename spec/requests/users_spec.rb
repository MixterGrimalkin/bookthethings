require 'rails_helper'

RSpec.describe 'Users API', type: :request do

  before {
    @user = create(:user)
    @provider = create(:provider)
    @customer = create(:customer)
    @both_user = create(:user)
    @both_provider = create(:provider, user: @both_user)
    @both_customer = create(:customer, user: @both_user)
  }

  describe 'POST /signup' do
    before {
      post '/signup', params: params, headers: invalid_headers
    }
    context 'when valid request' do
      let(:params) {
        attributes_for(:user, password_confirmation: @user.password).to_json
      }
      it 'responds with 201 (created)' do
        expect(response).to have_http_status(201)
      end
      it 'creates a new user' do
        expect(User.count).to eq(5)
      end
      it 'returns success message' do
        expect(json['message']).to match(/Account created successfully/)
      end
      it 'returns an authentication token' do
        expect(json['auth_token']).not_to be_nil
      end
    end
    context 'when email already exists' do
      let(:params) {
        attributes_for(:user, email: @user.email,
                       password_confirmation: @user.password).to_json
      }
      it 'responds with 422 (unprocessable entity)' do
        expect(response.status).to eq(422)
      end
      it 'responds with an error message' do
        expect(response.body).to match(/Email has already been taken/)
      end
    end
    context 'when invalid request' do
      let(:params) { {}.to_json }
      it 'responds with 422 (unprocessable entitiy)' do
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

  describe 'GET /user' do
    before {
      get '/user', params: {}, headers: headers
    }
    it_behaves_like 'authenticated controller'
    context 'when logged in as user' do
      let(:headers) { valid_headers(@user) }
      it 'responds with 200 (OK)' do
        expect(response.status).to eq(200)
      end
      it 'returns details of user' do
        expect(json.size).to eq(5)
        expect(compare_users(json, @user)).to be(true)
        expect(json['is_customer']).to be(false)
        expect(json['is_provider']).to be(false)
      end
    end
    context 'when logged in as customer' do
      let(:headers) { valid_headers(@customer.user) }
      it 'responds with 200 (OK)' do
        expect(response.status).to eq(200)
      end
      it 'returns details of customer user' do
        expect(json.size).to eq(5)
        expect(compare_users(json, @customer.user)).to be(true)
        expect(json['is_customer']).to be(true)
        expect(json['is_provider']).to be(false)
      end
    end
    context 'when logged in as provider' do
      let(:headers) { valid_headers(@provider.user) }
      it 'responds with 200 (OK)' do
        expect(response.status).to eq(200)
      end
      it 'returns details of provider user' do
        expect(json.size).to eq(5)
        expect(compare_users(json, @provider.user)).to be(true)
        expect(json['is_customer']).to be(false)
        expect(json['is_provider']).to be(true)
      end
    end
    context 'when logged in as customer and provider' do
      let(:headers) { valid_headers(@both_user) }
      it 'responds with 200 (OK)' do
        expect(response.status).to eq(200)
      end
      it 'returns details of customer and provider user' do
        expect(json.size).to eq(5)
        expect(compare_users(json, @both_user)).to be(true)
        expect(json['is_customer']).to be(true)
        expect(json['is_provider']).to be(true)
      end
    end
  end


end