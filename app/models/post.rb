# frozen_string_literal: true

class Post < ApplicationRecord
  belongs_to :user
  belongs_to :group

  validates :content, length: { maximum: 2000 }, presence: true

  def created_by?(user)
    return false unless user

    user_id == user.id
  end
end
