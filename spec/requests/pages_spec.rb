# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Pages', type: :request do
  describe 'GET /pp' do
    it 'renders a successful response' do
      get pp_path
      expect(response).to be_successful
    end
  end
end
