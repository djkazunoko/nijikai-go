# frozen_string_literal: true

class User < ApplicationRecord
  has_many :groups, foreign_key: :owner_id, dependent: :destroy, inverse_of: :owner

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
end
