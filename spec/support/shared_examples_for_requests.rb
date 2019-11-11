RSpec.shared_examples 'authenticated controller' do
  context 'when not logged in' do
    let(:headers) { invalid_headers }
    it 'responds with 422 (unprocessable entity)' do
      expect(response.status).to eq(422)
      expect(response.body).to match(/Missing token/)
    end
  end
end

RSpec.shared_examples 'provider-only controller' do
  context 'when logged in as non-provider' do
    let(:headers) { valid_headers(create(:user)) }
    it 'responds with 401 (unauthorized)' do
      expect(response.status).to eq(401)
      expect(response.body).to match(/User is not a provider/)
    end
  end
end

RSpec.shared_examples 'customer-only controller' do
  context 'when logged in as non-customer' do
    let(:headers) { valid_headers(create(:user)) }
    it 'responds with 401 (unauthorized)' do
      expect(response.status).to eq(401)
      expect(response.body).to match(/User is not a customer/)
    end
  end
end

