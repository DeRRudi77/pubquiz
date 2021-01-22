class Team < ApplicationRecord
  include Turbo::Broadcastable

  belongs_to :game

  before_create :generate_uuid

  after_update_commit { broadcast_replace_to 'teams' }

  private

  def generate_uuid
    self.uuid = SecureRandom.uuid
  end
end
