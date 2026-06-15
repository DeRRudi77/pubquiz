class AddUserToGames < ActiveRecord::Migration[7.1]
  def change
    # Nullable: existing games predate ownership and have no creator to backfill.
    # New games always set user_id (see GamesController#create).
    add_reference :games, :user, null: true, foreign_key: true, type: :uuid
  end
end
