require "test_helper"

class RoundTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end

# == Schema Information
#
# Table name: rounds
#
#  id                  :uuid             not null, primary key
#  game_id             :uuid             not null
#  number              :integer          not null
#  number_of_questions :integer          default(10)
#  status              :integer          default("pending_start")
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#
