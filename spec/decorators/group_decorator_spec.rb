# frozen_string_literal: true

require 'rails_helper'

RSpec.describe GroupDecorator do
  include Rails.application.routes.url_helpers
  let(:group) { create(:group).extend described_class }

  describe '#twitter_share_url' do
    it 'returns tweet web intent url' do
      query_params = {
        url: group_url(group),
        hashtags: "#{group.hashtag},2次会GO",
        text: "#{group.hashtag}の2次会に参加しよう！"
      }
      expected_url = "https://twitter.com/intent/tweet?#{URI.encode_www_form(query_params)}"
      expect(group.twitter_share_url).to eq expected_url
    end
  end
end
