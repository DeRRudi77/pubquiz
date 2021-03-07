require "test_helper"

class GameTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end

# == Schema Information
#
# Table name: games
#
#  id                   :uuid             not null, primary key
#  name                 :string
#  number_of_rounds     :integer          default(3)
#  number_of_teams      :integer          default(2)
#  current_round_number :integer          default(0)
#  status               :integer          default("pending_start")
#  created_at           :datetime         not null
#  updated_at           :datetime         not null
#
