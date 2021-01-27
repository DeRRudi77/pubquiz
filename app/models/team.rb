class Team < ApplicationRecord
  include Turbo::Broadcastable

  belongs_to :game
  has_many :answers

  after_update_commit { broadcast_replace_to 'teams' }
end
