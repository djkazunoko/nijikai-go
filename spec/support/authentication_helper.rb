# frozen_string_literal: true

OmniAuth.config.test_mode = true

module AuthenticationHelper
  def login_as(user)
    github_mock(user)
    if RSpec.current_example.metadata[:type] == :request
      get '/auth/github/callback'
    else
      visit '/auth/github/callback'
    end
  end

  def github_mock(user)
    OmniAuth.config.mock_auth[:github] = OmniAuth::AuthHash.new({
                                                                  provider: 'github',
                                                                  uid: user.uid,
                                                                  info: {
                                                                    nickname: user.name,
                                                                    image: user.image_url
                                                                  }
                                                                })
  end

  def github_invalid_mock
    OmniAuth.config.mock_auth[:github] = :invalid_credentials
  end
end

RSpec.configure do |config|
  config.include AuthenticationHelper
end
