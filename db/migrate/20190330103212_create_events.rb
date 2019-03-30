class CreateEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :events do |t|
      t.string :title
      t.text :description
      t.integer :min_people
      t.integer :max_people
      t.references :creator
      t.datetime :start
      t.datetime :end

      t.timestamps
    end
  end
end
