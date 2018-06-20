class CreateWriteModels < ActiveRecord::Migration[5.1]
  def up
    create_table :write_models do |t|
      t.string :type
      t.string :name
      t.integer :amount
      t.boolean :is_valid
      t.datetime :available_at
    end
  end

  def down
    drop_table :write_models
  end
end
