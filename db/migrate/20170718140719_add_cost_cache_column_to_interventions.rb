class AddCostCacheColumnToInterventions < ActiveRecord::Migration
  def change
    add_column :interventions, :input_cost, :decimal
  end
end
