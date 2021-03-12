class ChangeUniqueIndexOnTeam < ActiveRecord::Migration[6.1]
  def change
    remove_index :teams, :name
    add_index :teams, [:game_id, :name], unique: true
  end
end
