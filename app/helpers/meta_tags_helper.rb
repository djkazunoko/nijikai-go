# frozen_string_literal: true

module MetaTagsHelper
  def default_meta_tags
    {
      site: '2次会GO!',
      reverse: true,
      charset: 'utf-8',
      description: 'テックイベントの2次会参加者募集ツール',
      viewport: 'width=device-width, initial-scale=1.0',
      og:,
      twitter:
    }
  end

  private

  def og
    {
      site_name: :site,
      title: :title,
      description: :description,
      type: 'website',
      url: 'https://nijikai-go.fly.dev',
      local: 'ja-JP',
      image: image_url('ogp.png')
    }
  end

  def twitter
    {
      card: 'summary',
      image: image_url('ogp.png')
    }
  end
end
