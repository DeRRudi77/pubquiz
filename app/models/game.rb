class Game < ApplicationRecord
  has_many :rounds
  has_many :teams
  has_one :current_round, ->(game) { where(number: game.current_round_number) }, class_name: 'Round'
  has_one :next_round, ->(game) { where(number: game.current_round_number + 1) }, class_name: 'Round'
  enum status: %i[pending_start started finished], _default: "pending_start"

  validates :number_of_rounds, presence: true
  validates :name, presence: true

  after_create :create_rounds

  def next_round!
    started! unless started?
    current_round.finished! if current_round.present?
    next_round.started!
    update!(current_round_number: (current_round_number + 1))
    teams.reload.each { |team| team.reload.broadcast_replace_to 'teams' }
  end

  def reset!
    update(current_round_number: 0, status: :pending_start)
    rounds.update_all(status: :pending_start)
    teams.reload.each { |team| team.reload.broadcast_replace_to 'teams' }
  end

  def progress
    100 / number_of_rounds
  end

  private

  def create_rounds
    number_of_rounds.times do |number|
      rounds.create!(number: number + 1)
    end
  end
end
