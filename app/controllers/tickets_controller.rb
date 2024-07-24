# frozen_string_literal: true

class TicketsController < ApplicationController
  def create
    create_ticket_and_redirect(current_user, params[:group_id])
  end

  def destroy
    ticket = current_user.tickets.find_by!(group_id: params[:group_id])
    ticket.destroy!
    redirect_to group_path(params[:group_id]), notice: 'この2次会グループの参加をキャンセルしました'
  end
end
