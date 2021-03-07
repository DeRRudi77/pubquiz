class CreateTeams < ActiveRecord::Migration[6.1]
  def change
    create_table :teams, id: :uuid do |t|
      t.belongs_to :game, null: false, foreign_key: true, type: :uuid
      t.integer :number, null: false
      t.string :name

      t.timestamps
    end
  end
end
