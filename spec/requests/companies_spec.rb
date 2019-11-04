require 'rails_helper'

RSpec.describe 'Companies API', type: :request do

  let(:user) { create(:user) }
  let(:headers) { valid_headers }

  let!(:companies) { create_list(:company, 5) }
  let(:company_id) { companies.first.id }

  describe 'GET /companies' do
    before { get '/companies', params: {}, headers: headers }

    it 'returns all companies' do
      expect(json).not_to be_empty
      expect(json.size).to eq(5)
    end

    it 'returns status code 200' do
      expect(response).to have_http_status(200)
    end
  end

  describe 'GET /companies/:id' do
    before { get "/companies/#{company_id}", params: {}, headers: headers }

    context 'when record exists' do
      it 'returns the company' do
        expect(json).not_to be_empty
        expect(json['id']).to eq(company_id)
      end
      it 'returns status code 200' do
        expect(response).to have_http_status(200)
      end
    end

    context 'when record does not exist' do
      let(:company_id) { 100 }

      it 'returns status code 404' do
        expect(response).to have_http_status(404)
      end
      it 'returns a not found message' do
        expect(response.body).to match(/Couldn't find Company/)
      end
    end


  end
end