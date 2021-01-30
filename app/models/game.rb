class Game < ApplicationRecord
  has_many :rounds
  has_many :teams
  has_one :current_round, ->(game) { where(number: game.current_round_number) }, class_name: 'Round'
  has_one :next_round, ->(game) { where(number: game.current_round_number + 1) }, class_name: 'Round'
  enum status: %i[pending_start started finished], _default: "pending_start"

  validates :number_of_rounds, presence: true
  validates :name, presence: true

  after_create :create_rounds

  def start!
    rounds.create
  end

  def next_round!
    current_round.finished!
    rounds.create
    teams.reload.each { |team| team.reload.broadcast_replace_to 'teams' }
  end

  private

  def create_rounds
    number_of_rounds.times do |number|
      rounds.create!(number: number + 1)
    end
  end
end
