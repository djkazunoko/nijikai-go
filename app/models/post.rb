# frozen_string_literal: true

class Post < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :group

  validates :content, length: { maximum: 2000 }, presence: true

  def created_by?(user)
    return false unless user

    user_id == user.id
  end

  after_create_commit -> { broadcast_append_later_to 'posts', locals: { post: self, group: } }
  after_destroy_commit -> { broadcast_remove_to('posts') }
end
