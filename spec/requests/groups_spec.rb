# frozen_string_literal: true

require 'rails_helper'

RSpec.describe '/groups', type: :request do
  let!(:group) { create(:group) }
  let(:user) { create(:user) }
  let(:valid_attributes) { build(:group, owner: user).attributes }
  let(:invalid_attributes) { build(:group, :invalid, owner: user).attributes }

  describe 'GET /groups' do
    it 'renders a successful response' do
      get groups_url
      expect(response).to be_successful
    end
  end

  describe 'GET /groups/:id' do
    it 'renders a successful response' do
      get group_url(group)
      expect(response).to be_successful
    end
  end

  describe 'GET /groups/new' do
    context 'when user is logged in' do
      before do
        login_as(user)
      end

      it 'renders a successful response' do
        get new_group_url
        expect(response).to be_successful
      end
    end

    context 'when user is not logged in' do
      it 'redirects to root_path' do
        get new_group_url
        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe 'GET /groups/:id/edit' do
    context 'when logged in user is the group owner' do
      before do
        login_as(group.owner)
      end

      it 'renders a successful response' do
        get edit_group_url(group)
        expect(response).to be_successful
      end
    end

    context 'when logged in user is not the group owner' do
      before do
        login_as(user)
      end

      it 'returns a 404 response' do
        get edit_group_url(group)
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when user is not logged in' do
      it 'redirects to root_path' do
        get edit_group_url(group)
        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe 'POST /groups' do
    context 'when user is logged in' do
      before do
        login_as(user)
      end

      it 'creates a new Group with valid parameters' do
        expect do
          post groups_url, params: { group: valid_attributes }
        end.to change(Group, :count).by(1)

        expect(response).to redirect_to(group_url(Group.last))
      end

      it 'does not create a new Group with invalid parameters' do
        expect do
          post groups_url, params: { group: invalid_attributes }
        end.not_to change(Group, :count)

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when user is not logged in' do
      it 'does not create a new Group' do
        expect do
          post groups_url, params: { group: valid_attributes }
        end.not_to change(Group, :count)

        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe 'PATCH /groups/:id' do
    let(:new_attributes) { attributes_for(:group, name: 'New Group Name') }

    context 'when logged in user is the group owner' do
      before do
        login_as(group.owner)
      end

      it 'updates the group with valid parameters' do
        patch group_url(group), params: { group: new_attributes }
        group.reload
        expect(group.name).to eq 'New Group Name'
        expect(response).to redirect_to(group_url(group))
      end

      it 'does not update the group and renders a response with 422 status with invalid parameters' do
        patch group_url(group), params: { group: invalid_attributes }
        expect(response).to have_http_status(:unprocessable_entity)
      end

      it 'does not update the group and renders a response with 422 status when capacity is set less than the number of participants' do
        create_list(:ticket, 2, group:)
        patch group_url(group), params: { group: { capacity: 1 } }
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when logged in user is not the group owner' do
      before do
        login_as(user)
      end

      it 'returns a 404 response' do
        patch group_url(group), params: { group: new_attributes }
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when user is not logged in' do
      it 'redirects to root_path' do
        patch group_url(group), params: { group: new_attributes }
        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe 'DELETE /groups/:id' do
    context 'when logged in user is the group owner' do
      before do
        login_as(group.owner)
      end

      it 'deletes the group' do
        expect do
          delete group_url(group)
        end.to change(Group, :count).by(-1)

        expect(response).to redirect_to(groups_url)
      end
    end

    context 'when logged in user is not the group owner' do
      before do
        login_as(user)
      end

      it 'does not delete the group and returns a 404 response' do
        expect do
          delete group_url(group)
        end.not_to change(Group, :count)

        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when user is not logged in' do
      it 'does not delete the group and redirects to root_path' do
        expect do
          delete group_url(group)
        end.not_to change(Group, :count)

        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
