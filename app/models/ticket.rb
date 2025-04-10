# frozen_string_literal: true

class Ticket < ApplicationRecord
  belongs_to :user
  belongs_to :group

  validates :group_id, uniqueness: { scope: :user_id }
  validate :participants_cannot_exceed_capacity
  validate :owner_cannot_participate

  private

  def participants_cannot_exceed_capacity
    group.with_lock do
      errors.add(:base, '定員を超えて参加することはできません。') if group.tickets.count >= group.capacity
    end
  end

  def owner_cannot_participate
    return unless group.created_by?(user)

    errors.add(:base, '自身が主催したグループには参加できません。')
  end
end
