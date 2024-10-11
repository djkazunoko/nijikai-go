# frozen_string_literal: true

class Post < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :group

  validates :content, presence: true

  def created_by?(user)
    return false unless user

    user_id == user.id
  end
end
