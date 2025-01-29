class CreateLibraries < ActiveRecord::Migration[7.2]
  def change
    create_table :libraries do |t|
      t.string :formal
      t.string :url_pc

      t.timestamps
    end
  end
end
