# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Tickets', type: :request do
  let(:alice) { build(:user, :alice) }
  let(:group) { create(:group) }

  describe 'POST /create' do
    context 'when logged in and meeting the participation requirements' do
      before do
        github_mock(alice)
        login
      end

      it 'allows the user to join the group' do
        expect do
          post group_tickets_path(group)
        end.to change(Ticket, :count).by(1)
      end

      it 'displays a message after redirection' do
        post group_tickets_path(group)
        expect(response).to redirect_to(group_url(group))
        follow_redirect!
        expect(response.body).to include('2次会グループに参加しました')
      end
    end

    context 'when not logged in' do
      it 'does not allow the user to join the group' do
        expect do
          post group_tickets_path(group)
        end.not_to change(Ticket, :count)
      end

      it 'displays an error message after redirection' do
        post group_tickets_path(group)
        expect(response).to redirect_to(root_path)
        follow_redirect!
        expect(response.body).to include('ログインしてください')
      end
    end

    context 'when already participating in the group' do
      before do
        create(:ticket, user: alice, group:)
        github_mock(alice)
        login
      end

      it 'does not allow the user to join the group again' do
        expect do
          post group_tickets_path(group)
        end.not_to change(Ticket, :count)
      end

      it 'displays an error message after redirection' do
        post group_tickets_path(group)
        expect(response).to redirect_to(group_url(group))
        follow_redirect!
        expect(response.body).to include('この2次会グループには既に参加しています')
      end
    end

    context 'when the group has reached its capacity' do
      let(:full_capacity_group) { create(:group, :full_capacity) }

      before do
        github_mock(alice)
        login
      end

      it 'does not allow the user to join the group' do
        expect do
          post group_tickets_path(full_capacity_group)
        end.not_to change(alice.tickets, :count)
      end

      it 'displays an error message after redirection' do
        post group_tickets_path(full_capacity_group)
        expect(response).to redirect_to(group_url(full_capacity_group))
        follow_redirect!
        expect(response.body).to include('定員を超えて参加することはできません')
      end
    end

    context 'when the user is the group owner' do
      before do
        github_mock(group.owner)
        login
      end

      it 'does not allow the user to join the group' do
        expect do
          post group_tickets_path(group)
        end.not_to change(Ticket, :count)
      end

      it 'displays an error message after redirection' do
        post group_tickets_path(group)
        expect(response).to redirect_to(group_url(group))
        follow_redirect!
        expect(response.body).to include('自身が主催したグループには参加できません')
      end
    end
  end

  describe 'DELETE /destroy' do
    before do
      github_mock(alice)
      login
    end

    it 'allows the user to cancel participation' do
      post group_tickets_path(group)
      expect do
        delete group_ticket_path(group, Ticket.first)
      end.to change(Ticket, :count).by(-1)
    end

    it 'displays a message after redirection' do
      post group_tickets_path(group)
      delete group_ticket_path(group, Ticket.first)
      follow_redirect!
      expect(response.body).to include('この2次会グループの参加をキャンセルしました')
    end
  end
end
