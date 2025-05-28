class CreateProducts < ActiveRecord::Migration[7.0]
  def change
    create_table :products do |t|
      t.string :name
      t.integer :price
      t.integer :status, default: 0
      t.integer :stock_quantity, default: 0
      t.float :average_rating, default: 0.0

      t.timestamps
    end
  end
end
