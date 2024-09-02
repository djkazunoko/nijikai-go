# frozen_string_literal: true

class ApplicationController < ActionController::Base
  before_action :authenticate

  include UserSessionsHelper
  include TicketHelper
end
