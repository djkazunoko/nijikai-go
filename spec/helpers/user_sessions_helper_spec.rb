# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserSessionsHelper, type: :helper do
  let(:user) { create(:user) }

  describe '#current_user' do
    context 'when user is logged in' do
      before do
        session[:user_id] = user.id
      end

      it 'returns the current user' do
        expect(helper.current_user).to eq(user)
      end
    end

    context 'when user is not logged in' do
      it 'returns nil' do
        expect(helper.current_user).to be_nil
      end
    end
  end

  describe '#logged_in?' do
    context 'when user is logged in' do
      before do
        session[:user_id] = user.id
      end

      it 'returns true' do
        expect(helper).to be_logged_in
      end
    end

    context 'when user is not logged in' do
      it 'returns false' do
        expect(helper).not_to be_logged_in
      end
    end
  end
end
