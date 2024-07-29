# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Retirements', type: :request do
  before do
    github_mock(build(:user))
    login
  end

  describe 'POST /create' do
    it 'deletes the user from the database' do
      expect do
        post retirements_path
      end.to change(User, :count).by(-1)
    end

    it 'removes user id from session' do
      expect(session[:user_id]).to be_present
      post retirements_path
      expect(session[:user_id]).to be_nil
    end

    it 'redirects to root_path' do
      post retirements_path
      expect(response).to redirect_to(root_path)
    end
  end
end
