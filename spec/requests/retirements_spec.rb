# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Retirements', type: :request do
  describe 'POST /retirements' do
    let(:user) { create(:user) }
    let(:group) { create(:group) }

    context 'when no owned and participating groups exist' do
      before do
        login_as(user)
      end

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
        follow_redirect!
        expect(response.body).to include('アカウントが削除されました')
      end
    end

    context 'when owned groups exist' do
      before do
        login_as(group.owner)
      end

      it 'does not delete the user from the database' do
        expect do
          post retirements_path
        end.not_to change(User, :count)
      end

      it 'does not remove user id from session' do
        expect(session[:user_id]).to be_present
        post retirements_path
        expect(session[:user_id]).to be_present
      end

      it 'redirects to root_path' do
        post retirements_path
        expect(response).to redirect_to(root_path)
        follow_redirect!
        expect(response.body).to include('主催の2次会グループが存在するため、アカウントを削除できません')
      end
    end

    context 'when participating groups exist' do
      before do
        login_as(user)
        create(:ticket, user:, group:)
      end

      it 'does not delete the user from the database' do
        expect do
          post retirements_path
        end.not_to change(User, :count)
      end

      it 'does not remove user id from session' do
        expect(session[:user_id]).to be_present
        post retirements_path
        expect(session[:user_id]).to be_present
      end

      it 'redirects to root_path' do
        post retirements_path
        expect(response).to redirect_to(root_path)
        follow_redirect!
        expect(response.body).to include('参加中の2次会グループが存在するため、アカウントを削除できません')
      end
    end

    context 'when the user is NOT logged in' do
      before do
        create(:ticket, user:, group:)
      end

      it 'does not delete the user from the database' do
        expect do
          post retirements_path
        end.not_to change(User, :count)
      end

      it 'redirects to root_path' do
        post retirements_path
        expect(response).to redirect_to(root_path)
        follow_redirect!
        expect(response.body).to include('ログインしてください')
      end
    end
  end
end
