require 'rails_helper'

RSpec.describe AuthorizeApiRequest do

  let(:user) { create(:user) }

  subject(:valid_request) { described_class.new({'Authorization' => token_generator(user.id)}) }
  subject(:missing_token) { described_class.new({}) }
  subject(:invalid_token) { described_class.new({'Authorization' => token_generator(5)}) }
  subject(:expired_token) { described_class.new({'Authorization' => expired_token_generator(user.id)}) }
  subject(:fake_token) { described_class.new({'Authorization' => 'foobar'}) }

  describe '#call' do

    context 'when valid request' do
      it 'returns user object' do
        result = valid_request.call
        expect(result[:user]).to eq(user)
      end
    end

    context 'when invalid request' do
      context 'when missing token' do
        it 'raises a MissingToken error' do
          expect { missing_token.call }
              .to raise_error(ExceptionHandler::MissingToken, 'Missing token')
        end
      end
      context 'when invalid token' do
        it 'raises an InvalidToken error' do
          expect { invalid_token.call }
              .to raise_error(ExceptionHandler::InvalidToken, /Invalid token/)
        end
      end
      context 'when token is expired' do
        it 'raises ExpiredSignature error' do
          expect { expired_token.call }
              .to raise_error(ExceptionHandler::InvalidToken, /Signature has expired/)
        end
      end
      context 'fake token' do
        it 'raises InvalidToken error' do
          expect { fake_token.call }
              .to raise_error(ExceptionHandler::InvalidToken, /Not enough or too many segments/)
        end
      end
    end

  end

end