# frozen_string_literal: true

module TicketHelper
  def create_ticket_and_redirect(user, group_id)
    group = Group.find(group_id)
    ticket = user.tickets.build(group:)
    if ticket.save
      redirect_to group, notice: '2次会グループに参加しました。'
    else
      redirect_to group, alert: ticket.errors.full_messages.to_sentence
    end
  end
end
