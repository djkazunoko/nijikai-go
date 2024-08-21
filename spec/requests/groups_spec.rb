# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/groups', type: :request do
  let(:owner) { create(:user) }
  let(:alice) { build(:user, :alice) }
  let(:valid_attributes) { build(:group, owner:).attributes }
  let(:invalid_attributes) { build(:group, :invalid, owner:).attributes }

  describe 'GET /index' do
    it 'renders a successful response' do
      Group.create! valid_attributes
      get groups_url
      expect(response).to be_successful
    end
  end

  describe 'GET /show' do
    it 'renders a successful response' do
      group = Group.create! valid_attributes
      get group_url(group)
      expect(response).to be_successful
    end
  end

  describe 'GET /new' do
    context 'when authenticated' do
      before do
        github_mock(alice)
        login
      end

      it 'renders a successful response' do
        get new_group_url
        expect(response).to be_successful
      end
    end

    context 'when not authenticated' do
      it 'returns a 302 response' do
        get new_group_url
        expect(response).to have_http_status(:found)
      end
    end
  end

  describe 'GET /edit' do
    context 'when owner' do
      before do
        github_mock(owner)
        login
      end

      it 'renders a successful response' do
        group = Group.create! valid_attributes
        get edit_group_url(group)
        expect(response).to be_successful
      end
    end

    context 'when other user' do
      before do
        github_mock(alice)
        login
      end

      it 'returns a 404 response' do
        group = Group.create! valid_attributes
        get edit_group_url(group)
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when guest' do
      it 'returns a 302 response' do
        group = Group.create! valid_attributes
        get edit_group_url(group)
        expect(response).to have_http_status(:found)
      end
    end
  end

  describe 'POST /create' do
    context 'when authenticated' do
      before do
        github_mock(alice)
        login
      end

      it 'creates a new Group with valid parameters' do
        expect do
          post groups_url, params: { group: valid_attributes }
        end.to change(Group, :count).by(1)
      end

      it 'redirects to the created group with valid parameters' do
        post groups_url, params: { group: valid_attributes }
        expect(response).to redirect_to(group_url(Group.last))
      end

      it 'does not create a new Group with invalid parameters' do
        expect do
          post groups_url, params: { group: invalid_attributes }
        end.to change(Group, :count).by(0)
      end

      it 'renders a response with 422 status with invalid parameters' do
        post groups_url, params: { group: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when not authenticated' do
      it 'returns a 302 response' do
        post groups_url, params: { group: valid_attributes }
        expect(response).to have_http_status(:found)
      end
    end
  end

  describe 'PATCH /update' do
    let(:new_attributes) { attributes_for(:group, name: 'New Group Name') }

    context 'when owner' do
      before do
        github_mock(owner)
        login
      end

      it 'updates the requested group with valid parameters' do
        group = Group.create! valid_attributes
        patch group_url(group), params: { group: new_attributes }
        group.reload
        expect(group.name).to eq 'New Group Name'
      end

      it 'redirects to the group with valid parameters' do
        group = Group.create! valid_attributes
        patch group_url(group), params: { group: new_attributes }
        group.reload
        expect(response).to redirect_to(group_url(group))
      end

      it 'renders a response with 422 status with invalid parameters' do
        group = Group.create! valid_attributes
        patch group_url(group), params: { group: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when other user' do
      before do
        github_mock(alice)
        login
      end

      it 'returns a 404 response' do
        group = Group.create! valid_attributes
        patch group_url(group), params: { group: new_attributes }
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when guest' do
      it 'returns a 302 response' do
        group = Group.create! valid_attributes
        patch group_url(group), params: { group: new_attributes }
        expect(response).to have_http_status(:found)
      end
    end
  end

  describe 'DELETE /destroy' do
    context 'when owner' do
      before do
        github_mock(owner)
        login
      end

      it 'destroys the requested group' do
        group = Group.create! valid_attributes
        expect do
          delete group_url(group)
        end.to change(Group, :count).by(-1)
      end

      it 'redirects to the groups list' do
        group = Group.create! valid_attributes
        delete group_url(group)
        expect(response).to redirect_to(groups_url)
      end
    end

    context 'when other user' do
      before do
        github_mock(alice)
        login
      end

      it 'returns a 404 response' do
        group = Group.create! valid_attributes
        delete group_url(group)
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when guest' do
      it 'returns a 302 response' do
        group = Group.create! valid_attributes
        delete group_url(group)
        expect(response).to have_http_status(:found)
      end
    end
  end
end
