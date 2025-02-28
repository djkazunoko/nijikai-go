# frozen_string_literal: true

class PagesController < ApplicationController
  skip_before_action :authenticate
  def pp; end
  def tos; end
end
