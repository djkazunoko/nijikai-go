# frozen_string_literal: true

class Post < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :group

  validates :content, presence: true
  validate :user_cannot_post_if_not_member_or_owner

  private

  def user_cannot_post_if_not_member_or_owner
    return if group.created_by?(user) || group.tickets.exists?(user:)

    errors.add(:base, 'このグループに参加していないため、投稿できません')
  end
end
