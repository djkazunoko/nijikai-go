# frozen_string_literal: true

namespace :groups do
  desc 'Destroy all groups and their associated tickets and posts'
  task destroy_all: :environment do
    Group.destroy_all
  end
end
