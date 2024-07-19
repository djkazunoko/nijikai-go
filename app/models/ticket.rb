# frozen_string_literal: true

class Ticket < ApplicationRecord
  belongs_to :user
  belongs_to :group

  validates :group_id, uniqueness: { scope: :user_id }
  validate :participants_cannot_exceed_capacity

  private

  def participants_cannot_exceed_capacity
    return unless group.tickets.count >= group.capacity

    errors.add(:base, '定員を超えて参加することはできません')
  end
end
