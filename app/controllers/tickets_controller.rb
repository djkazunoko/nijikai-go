# frozen_string_literal: true

class TicketsController < ApplicationController
  def create
    group = Group.find(params[:group_id])
    ticket = current_user.tickets.build(group:)
    if ticket.save
      redirect_to group, notice: '2次会グループに参加しました'
    end
  end
end
