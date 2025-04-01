# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Tickets', type: :request do
  let(:group) { create(:group) }

  shared_context 'when the user is logged in' do
    let(:user) { create(:user) }

    before do
      login_as(user)
    end
  end

  shared_context 'when the user is NOT logged in' do
    let(:user) { create(:user) }

    before do
      github_mock(user)
    end
  end

  describe 'POST /groups/:id/tickets' do
    context 'when the user is logged in AND is NOT the owner of the group AND is NOT a member of the group AND the group is NOT full' do
      include_context 'when the user is logged in'

      it 'allows the user to join the group' do
        expect do
          post group_tickets_path(group)
        end.to change(Ticket, :count).by(1)
        expect(response).to redirect_to(group_path(group))
        follow_redirect!
        expect(response.body).to include('2次会グループに参加しました。')
      end
    end

    context 'when the user is logged in AND is the owner of the group' do
      include_context 'when the user is logged in'
      let(:group) { create(:group, owner: user) }

      it 'does not allow the user to join the group' do
        expect do
          post group_tickets_path(group)
        end.not_to change(Ticket, :count)
        expect(response).to redirect_to(group_path(group))
        follow_redirect!
        expect(response.body).to include('自身が主催したグループには参加できません。')
      end
    end

    context 'when the user is logged in AND is a member of the group' do
      include_context 'when the user is logged in'

      before do
        create(:ticket, user:, group:)
      end

      it 'does not allow the user to join the group' do
        expect do
          post group_tickets_path(group)
        end.not_to change(Ticket, :count)
        expect(response).to redirect_to(group_path(group))
        follow_redirect!
        expect(response.body).to include('この2次会グループには既に参加しています。')
      end
    end

    context 'when the user is logged in AND the group is full' do
      include_context 'when the user is logged in'
      let(:full_capacity_group) { create(:group, :full_capacity) }

      it 'does not allow the user to join the group' do
        expect do
          post group_tickets_path(full_capacity_group)
        end.not_to change(user.tickets, :count)
        expect(response).to redirect_to(group_path(full_capacity_group))
        follow_redirect!
        expect(response.body).to include('定員を超えて参加することはできません。')
      end
    end

    context 'when the user is NOT logged in' do
      include_context 'when the user is NOT logged in'

      it 'does not allow the user to join the group and redirects to root_path' do
        expect do
          post group_tickets_path(group)
        end.not_to change(Ticket, :count)
        expect(response).to redirect_to(root_path)
        follow_redirect!
        expect(response.body).to include('ログインしてください。')
      end
    end
  end

  describe 'DELETE /groups/:id/tickets/:id' do
    context 'when the user is logged in AND is a member of the group' do
      include_context 'when the user is logged in'
      before do
        create(:ticket, user:, group:)
      end

      it 'allows the user to cancel participation' do
        expect do
          delete group_ticket_path(group, Ticket.first)
        end.to change(Ticket, :count).by(-1)
        expect(response).to redirect_to(group_path(group))
        follow_redirect!
        expect(response.body).to include('2次会グループへの参加をキャンセルしました。')
      end
    end

    context 'when the user is logged in AND is NOT a member of the group' do
      include_context 'when the user is logged in'
      before do
        create(:ticket, group:)
      end

      it 'does not allow the user to cancel participation and returns a 404 response' do
        expect do
          delete group_ticket_path(group, Ticket.first)
        end.not_to change(Ticket, :count)
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'when the user is NOT logged in AND is a member of the group' do
      include_context 'when the user is NOT logged in'
      before do
        create(:ticket, user:, group:)
      end

      it 'does not allow the user to cancel participation and redirects to root_path' do
        expect do
          delete group_ticket_path(group, Ticket.first)
        end.not_to change(Ticket, :count)
        expect(response).to redirect_to(root_path)
        follow_redirect!
        expect(response.body).to include('ログインしてください。')
      end
    end
  end
end
