class CreateTraces < ActiveRecord::Migration[5.2]
  def change
    create_table :traces do |t|
      t.jsonb :request, null: false
      t.jsonb :response, null: false
      t.timestamp :request_ts, null: false
      t.timestamp :response_ts, null: false
      t.references :service_version, foreign_key: true

      t.timestamps
    end

    add_index :traces, :request_ts
    add_index :traces, :response_ts
  end
end
