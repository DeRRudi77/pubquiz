class RenameNameToTitle < ActiveRecord::Migration[6.1]
  def change
    add_column :rounds, :title, :string
  end
end
