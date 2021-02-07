class CreateGames < ActiveRecord::Migration[6.1]
  def change
    create_table :games, id: :uuid do |t|
      t.string :name, nil: false
      t.integer :number_of_rounds, default: 3
      t.integer :number_of_teams, default: 2
      t.integer :current_round_number, nil: true, default: 0
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
