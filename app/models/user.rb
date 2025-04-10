# frozen_string_literal: true

class User < ApplicationRecord
  before_destroy :ensure_no_owned_groups
  before_destroy :ensure_no_participating_groups

  has_many :groups, foreign_key: :owner_id, dependent: :destroy, inverse_of: :owner
  has_many :tickets, dependent: :destroy
  has_many :posts, dependent: :destroy

  validates :provider, presence: true
  validates :uid, presence: true, uniqueness: { scope: :provider }
  validates :name, presence: true, uniqueness: true
  validates :image_url, presence: true, uniqueness: true

  def self.find_or_create_from_auth_hash!(auth_hash)
    provider = auth_hash[:provider]
    uid = auth_hash[:uid]
    nickname = auth_hash[:info][:nickname]
    image_url = auth_hash[:info][:image]

    User.find_or_create_by!(provider:, uid:) do |user|
      user.name = nickname
      user.image_url = image_url
    end
  end

  private

  def ensure_no_owned_groups
    return unless groups.exists?

    errors.add(:base, '主催の2次会グループが存在するため、アカウントを削除できません。')
    throw(:abort)
  end

  def ensure_no_participating_groups
    return unless tickets.exists?

    errors.add(:base, '参加中の2次会グループが存在するため、アカウントを削除できません。')
    throw(:abort)
  end
end
