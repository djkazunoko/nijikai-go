# frozen_string_literal: true

module GroupDecorator
  def twitter_share_url
    # https://developer.x.com/en/docs/x-for-websites/tweet-button/guides/web-intent
    query_params = {
      url: Rails.application.routes.url_helpers.group_url(self),
      hashtags: "#{hashtag},2次会GO",
      text: "#{hashtag}の2次会に参加しよう！"
    }
    "https://twitter.com/intent/tweet?#{URI.encode_www_form(query_params)}"
  end
end
