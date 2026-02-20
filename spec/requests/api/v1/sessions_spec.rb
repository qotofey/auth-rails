# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Api::V1::Sessions', type: :request do
  let(:user) { User.create! }
  let(:credential) { UserCredential.create!(user: user, login: 'testuser', kind: :username) }
  let(:password) { UserPassword.create!(user: user, password: 'Qwerty123456') }

  describe 'POST /api/v1/session' do
    context 'when data is missing' do
      it 'returns 422 with error on data' do
        post '/api/v1/session', params: {}, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['errors'].size).to eq(1)
        expect(json['errors'][0]['source']['pointer']).to eq('/data')
      end
    end

    context 'when data is empty' do
      it 'returns 422 with error on type' do
        post '/api/v1/session', params: { data: {} }, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['errors'].any? { |e| e['source']['pointer'] == '/data/type' }).to be true
      end
    end

    context 'when type is invalid' do
      it 'returns 422 with error on type' do
        post '/api/v1/session', params: { data: { type: 'wrong' } }, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['errors'].any? { |e| e['source']['pointer'] == '/data/type' }).to be true
      end
    end

    context 'when attributes is missing' do
      it 'returns 422 with error on attributes' do
        post '/api/v1/session', params: { data: { type: 'users' } }, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['errors'].any? { |e| e['source']['pointer'] == '/data/attributes' }).to be true
      end
    end

    context 'when credentials are invalid' do
      it 'returns 422 with invalid credentials error' do
        post '/api/v1/session', params: {
          data: {
            type: 'users',
            attributes: {
              username: 'wronguser',
              password: 'Qwerty123456'
            }
          }
        }, as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        json = JSON.parse(response.body)
        expect(json['errors'][0]['title']).to eq('Неверный логин или пароль')
      end
    end

    context 'when credentials are valid' do
      it 'creates session and returns access token' do
        post '/api/v1/session', params: {
          data: {
            type: 'users',
            attributes: {
              username: 'testuser',
              password: 'Qwerty123456'
            }
          }
        }, as: :json
        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['meta']['accessToken']).to be_present
        expect(response.cookies['refresh_token']).to be_present
      end
    end
  end

  describe 'PUT /api/v1/session' do
    let(:refresh_token) { SecureRandom.alphanumeric(64) }
    let!(:session) { UserSession.create!(user_credential: credential, token: refresh_token) }

    context 'when refresh token is missing' do
      it 'returns 401' do
        put '/api/v1/session', as: :json
        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json['errors'][0]['status']).to eq('401')
      end
    end

    context 'when refresh token is invalid' do
      it 'returns 401' do
        request.cookies[:refresh_token] = 'invalid_token'
        put '/api/v1/session', as: :json
        expect(response).to have_http_status(:unauthorized)
      end
    end

    context 'when refresh token is valid' do
      it 'creates new tokens and returns 201' do
        request.cookies[:refresh_token] = refresh_token
        put '/api/v1/session', as: :json
        expect(response).to have_http_status(:created)
        json = JSON.parse(response.body)
        expect(json['meta']['accessToken']).to be_present
      end
    end
  end

  describe 'DELETE /api/v1/session' do
    let(:refresh_token) { SecureRandom.alphanumeric(64) }
    let!(:session) { UserSession.create!(user_credential: credential, token: refresh_token) }

    context 'when refresh token is present' do
      it 'deletes session and returns 204' do
        request.cookies[:refresh_token] = refresh_token
        delete '/api/v1/session', as: :json
        expect(response).to have_http_status(:no_content)
      end
    end

    context 'when refresh token is missing' do
      it 'returns 204' do
        delete '/api/v1/session', as: :json
        expect(response).to have_http_status(:no_content)
      end
    end
  end
end
