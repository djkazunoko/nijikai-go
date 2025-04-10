# frozen_string_literal: true

class TicketsController < ApplicationController
  include TicketCreation

  def create
    create_ticket_and_redirect(current_user, params[:group_id])
  end

  def destroy
    ticket = current_user.tickets.find_by!(group_id: params[:group_id])
    ticket.destroy!
    redirect_to group_path(params[:group_id]), notice: '2次会グループへの参加をキャンセルしました。'
  end
end
