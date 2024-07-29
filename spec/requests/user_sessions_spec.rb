# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'UserSessions', type: :request do
  before do
    github_mock(build(:user))
  end

  describe 'POST /create' do
    context 'with valid parameters' do
      it 'creates a new user' do
        expect do
          get '/auth/github/callback'
        end.to change(User, :count).by(1)
      end

      it 'saves user id to session' do
        get '/auth/github/callback'
        expect(session[:user_id]).to be_present
      end

      it 'redirects to new_group_path' do
        get '/auth/github/callback'
        expect(response).to redirect_to(new_group_path)
      end
    end

    context 'with invalid parameters' do
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

  describe 'DELETE /destroy' do
    it 'removes user id from session' do
      get '/auth/github/callback'
      expect(session[:user_id]).to be_present
      delete '/logout'
      expect(session[:user_id]).to be_nil
    end

    it 'redirects to root_path' do
      delete '/logout'
      expect(response).to redirect_to(root_path)
    end
  end

  describe 'GET /failure' do
    it 'redirects to root_path' do
      get '/auth/failure'
      expect(response).to redirect_to(root_path)
    end
  end
end
