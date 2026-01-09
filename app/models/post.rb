# frozen_string_literal: true

class Post < ApplicationRecord
  belongs_to :user
  belongs_to :group

  validates :content, length: { maximum: 1000 }, presence: true

  def created_by?(user)
    return false unless user

    user_id == user.id
  end

  after_create_commit -> { broadcast_append_to('posts') }
  after_create_commit -> { broadcast_append_to user, target: "delete_button_#{id}", partial: 'posts/delete_button', locals: { post: self, group: } }
  after_destroy_commit -> { broadcast_remove_to('posts') }
end
