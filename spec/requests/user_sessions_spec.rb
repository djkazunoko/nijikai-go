# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'UserSessions', type: :request do
  describe 'GET /auth/:provider/callback' do
    context 'with valid authentication parameters' do
      before do
        github_mock(build(:user))
      end

      it 'creates a new user' do
        expect do
          get '/auth/github/callback'
        end.to change(User, :count).by(1)
      end

      it 'saves user id to session' do
        get '/auth/github/callback'
        expect(session[:user_id]).to be_present
      end

      it 'redirects to root_path' do
        get '/auth/github/callback'
        expect(response).to redirect_to(root_path)
        follow_redirect!
        expect(response.body).to include('ログインしました。')
      end
    end

    context 'with invalid authentication parameters' do
      before do
        github_invalid_mock
      end

      it 'does not create a new user' do
        expect do
          get '/auth/github/callback'
        end.not_to change(User, :count)
      end

      it 'does not save user id to session' do
        get '/auth/github/callback'
        expect(session[:user_id]).to be_nil
      end

      it 'redirects to /auth/failure' do
        get '/auth/github/callback'
        expect(response.redirect_url).to include('/auth/failure')
      end
    end
  end

  describe 'DELETE /logout' do
    before do
      login_as(build(:user))
    end

    it 'removes user id from session' do
      expect(session[:user_id]).to be_present
      delete '/logout'
      expect(session[:user_id]).to be_nil
    end

    it 'redirects to root_path' do
      delete '/logout'
      expect(response).to redirect_to(root_path)
      follow_redirect!
      expect(response.body).to include('ログアウトしました。')
    end
  end

  describe 'GET /auth/failure' do
    it 'redirects to root_path' do
      get '/auth/failure'
      expect(response).to redirect_to(root_path)
      follow_redirect!
      expect(response.body).to include('ログインをキャンセルしました。')
    end
  end
end
