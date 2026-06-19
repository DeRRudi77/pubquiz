require "test_helper"

class TeamTest < ActiveSupport::TestCase
  include Turbo::Broadcastable::TestHelper

  test "broadcast_team_replace replaces the frame on both the captain and viewer streams" do
    team = teams(:one)

    captain_streams = capture_turbo_stream_broadcasts([team, :captain]) do
      viewer_streams = capture_turbo_stream_broadcasts([team, :viewer]) do
        team.broadcast_team_replace
      end
      assert_equal 1, viewer_streams.size
      assert_equal "replace", viewer_streams.first["action"]
    end

    assert_equal 1, captain_streams.size
    assert_equal "replace", captain_streams.first["action"]
  end

  test "name must be unique within a game" do
    existing = teams(:one)
    dup = existing.game.teams.build(name: existing.name, number: 99)
    assert_not dup.valid?
    assert_includes dup.errors[:name], "has already been taken"
  end

  test "the same name is allowed in a different game" do
    existing = teams(:one)
    other = games(:two).teams.build(name: existing.name, number: 99)
    assert other.valid?, other.errors.full_messages.to_sentence
  end
end

# == Schema Information
#
# Table name: teams
#
#  id         :uuid             not null, primary key
#  game_id    :uuid             not null
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
