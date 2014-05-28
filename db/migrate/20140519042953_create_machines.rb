class CreateMachines < ActiveRecord::Migration
  def change
    create_table :machines do |t|
      t.string :ip
      t.integer :user_id
      t.integer :high,default: -1
      t.integer :mid,default: -1
      t.integer :low,default: -1
      t.integer :status,default: 3

      t.timestamps
    end
  end
end
