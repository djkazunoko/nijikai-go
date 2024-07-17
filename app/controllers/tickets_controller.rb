# frozen_string_literal: true

class TicketsController < ApplicationController
  def create
    group = Group.find(params[:group_id])
    ticket = current_user.tickets.build(group:)
    if ticket.save
      redirect_to group, notice: '2次会グループに参加しました'
    end
  end

  def destroy
    ticket = current_user.tickets.find_by!(group_id: params[:group_id])
    ticket.destroy!
    redirect_to group_path(params[:group_id]), notice: 'この2次会グループの参加をキャンセルしました'
  end
end
