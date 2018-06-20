class CreateReadModels < ActiveRecord::Migration[5.1]
  def up
    create_table :read_models do |t|
      t.integer :write_model_id
      t.integer :save_count
    end
  end

  def down
    drop_table :read_models
  end
end
