# frozen_string_literal: true

module MetaTagsHelper
  def default_meta_tags
    {
      site: '2次会GO!',
      reverse: true,
      charset: 'utf-8',
      description: 'テックイベントの2次会参加者募集ツール',
      viewport: 'width=device-width, initial-scale=1.0'
    }
  end
end
