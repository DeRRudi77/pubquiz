class AddTotalPointsToTeam < ActiveRecord::Migration[6.1]
  def change
    add_column :teams, :total_points, :float
  end
end
