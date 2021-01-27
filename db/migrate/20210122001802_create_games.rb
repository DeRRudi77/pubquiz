class CreateGames < ActiveRecord::Migration[6.1]
  def change
    create_table :games, id: :uuid do |t|
      t.string :name, nil: false
      t.integer :number_of_rounds
      t.integer :current_round_number, nil: true, default: 0
      t.integer :status

      t.timestamps
    end
  end
end
