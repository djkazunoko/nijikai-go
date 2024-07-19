# frozen_string_literal: true

class Group < ApplicationRecord
  belongs_to :owner, class_name: 'User', inverse_of: :groups
  has_many :tickets, dependent: :destroy

  validates :hashtag, presence: true
  validates :name, presence: true
  validates :details, presence: true
  validates :capacity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :location, presence: true
  validates :payment_method, presence: true

  def created_by?(user)
    return false unless user

    owner_id == user.id
  end

  def can_participate?
    tickets.count < capacity
  end
end
