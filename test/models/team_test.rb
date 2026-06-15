require "test_helper"

class TeamTest < ActiveSupport::TestCase
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
