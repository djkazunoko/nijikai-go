# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Ticket, type: :model do
  subject { build(:ticket) }

  it { is_expected.to validate_uniqueness_of(:group_id).scoped_to(:user_id) }
end
