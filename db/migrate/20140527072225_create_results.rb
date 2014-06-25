class CreateResults < ActiveRecord::Migration
  def change
    create_table :results do |t|
      t.integer :machine_id
      t.string :port
      t.string :threat
      t.text :description
      t.text :xref

      t.timestamps
    end
  end
end
