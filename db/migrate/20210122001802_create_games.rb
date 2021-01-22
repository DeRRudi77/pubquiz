class CreateGames < ActiveRecord::Migration[6.1]
  def change
    create_table :games, id: :uuid do |t|
      t.string :name, nil: false
      t.string :status

      t.timestamps
    end
  end
end
