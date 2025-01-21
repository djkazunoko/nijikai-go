# frozen_string_literal: true

class Group < ApplicationRecord
  belongs_to :owner, class_name: 'User', inverse_of: :groups
  has_many :tickets, dependent: :destroy
  has_many :posts, dependent: :destroy

  validates :hashtag, presence: true, length: { maximum: 50 }
  validates :name, presence: true, length: { maximum: 50 }
  validates :details, presence: true, length: { maximum: 2000 }
  validates :capacity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :location, presence: true, length: { maximum: 100 }
  validates :payment_method, presence: true, length: { maximum: 50 }

  validate :capacity_cannot_be_less_than_participants, on: :update

  def created_by?(user)
    return false unless user

    owner_id == user.id
  end

  def full_capacity?
    tickets.count >= capacity
  end

  private

  def capacity_cannot_be_less_than_participants
    return unless capacity < tickets.count

    errors.add(:capacity, 'は参加人数以上の値にしてください')
  end
end
