# frozen_string_literal: true

class Post < ApplicationRecord
  belongs_to :user
  belongs_to :group

  validates :content, length: { maximum: 1000 }, presence: true

  def created_by?(user)
    return false unless user

    user_id == user.id
  end

  after_create_commit lambda {
    broadcast_append_to group,
                        target: 'posts',
                        partial: 'posts/post',
                        locals: { group:, broadcasted: true }
  }
  after_destroy_commit -> { broadcast_remove_to group }
end
