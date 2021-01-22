class Game < ApplicationRecord
  has_many :rounds
  has_many :teams
  has_one :current_round, -> { started }, class_name: 'Round'
  enum status: %i[not_started started ended finished], _default: "not_started"

  def start!
    rounds.create
  end

  def next_round!
    current_round.update ended: true
    rounds.create
    teams.reload.each { |team| team.reload.broadcast_replace_to 'teams' }
  end
end
