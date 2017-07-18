class AddCostCacheColumnToInterventions < ActiveRecord::Migration
  def change
    add_column :interventions, :cost, :decimal
  end
end
