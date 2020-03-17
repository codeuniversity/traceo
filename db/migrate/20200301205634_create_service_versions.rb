class CreateServiceVersions < ActiveRecord::Migration[5.2]
  def change
    create_table :service_versions do |t|
      t.string :version, null: false
      t.references :service, foreign_key: true, null: false

      t.timestamps
    end

    add_index :service_versions, [:service_id, :version], unique: true
  end
end
