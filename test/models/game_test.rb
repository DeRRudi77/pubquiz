require "test_helper"

class GameTest < ActiveSupport::TestCase
  setup { @owner = users(:owner) }

  test "auto-creates rounds numbered sequentially" do
    game = @owner.games.create!(name: "Numbered", number_of_rounds: 3, number_of_teams: 1)
    assert_equal [1, 2, 3], game.rounds.order(:number).pluck(:number)
  end

  test "progress returns 0 instead of dividing by zero" do
    game = @owner.games.create!(name: "Zero", number_of_rounds: 0, number_of_teams: 0)
    assert_equal 0, game.progress
  end

  test "next_round! does not raise past the final round" do
    game = @owner.games.create!(name: "Last", number_of_rounds: 1, number_of_teams: 1)
    game.update_columns(status: Game.statuses[:started], current_round_number: 1)

    assert_nothing_raised { game.next_round! }
    assert_equal 1, game.current_round_number, "should not advance past the last round"
  end
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
