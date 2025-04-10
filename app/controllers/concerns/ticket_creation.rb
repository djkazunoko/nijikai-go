# frozen_string_literal: true

module TicketCreation
  extend ActiveSupport::Concern

  private

  def create_ticket_and_redirect(user, group_id)
    group = Group.find(group_id)

    group.with_lock do
      ticket = user.tickets.build(group:)
      if ticket.save
        redirect_to group, notice: '2次会グループに参加しました。'
      else
        redirect_to group, alert: ticket.errors.full_messages.to_sentence
      end
    end
  end
end
