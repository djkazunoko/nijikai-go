# frozen_string_literal: true

class Group < ApplicationRecord
  belongs_to :owner, class_name: 'User', inverse_of: :groups
  has_many :tickets, dependent: :destroy
  has_many :posts, dependent: :destroy

  validates :hashtag, presence: true, length: { maximum: 50 }, format: { with: /\A[\p{Alnum}_]+\z/, message: 'にはスペースや記号は使用できません。' }
  validates :details, presence: true, length: { maximum: 2000 }
  validates :capacity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :location, presence: true, length: { maximum: 100 }
  validates :payment_method, presence: true, length: { maximum: 50 }

  validate :capacity_cannot_be_less_than_participants, on: :update
  validate :hashtag_cannot_be_numbers_or_underscores_only

  def created_by?(user)
    return false unless user

    owner_id == user.id
  end

  def full_capacity?
    tickets.count >= capacity
  end

  def remaining_slots
    capacity - tickets.count
  end

  private

  def capacity_cannot_be_less_than_participants
    return unless capacity < tickets.count

    errors.add(:capacity, 'は参加人数以上の値にしてください')
  end

  def hashtag_cannot_be_numbers_or_underscores_only
    return if hashtag.blank?
    return unless hashtag.match?(/\A[0-9_]+\z/)

    errors.add(:hashtag, 'は数字、アンダースコアのみでは登録できません')
  end
end
