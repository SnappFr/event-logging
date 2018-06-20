class CreateEventLoggingEvents < ActiveRecord::Migration[5.1]
  def up
    create_table :event_logging_events do |t|
      t.string :stream_id, null: false, index: true
      t.string :aggregate_name, null: false, index: true
      t.string :action, null: false
      t.jsonb :payload, default: {}, null: false
      t.datetime :created_at, null: false
    end
  end

  def down
    drop_table :event_logging_events
  end
end
