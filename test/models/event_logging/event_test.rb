require 'test_helper'

class WriteModel < ApplicationRecord
  include EventLogging::Writer
end

class ReadModel < ApplicationRecord
  include EventLogging::Reader

  register_write_models WriteModel

  class << self
    def handle_event_log(event)
      read_model = ReadModel.create_with(save_count: 0).find_or_create_by(id: event.stream_id)
      read_model.increment!(:save_count)
    end
  end
end

module EventLogging
  class EventTest < ActiveSupport::TestCase

    setup do
      Time.zone.stubs(now: Time.zone.now)
    end

    test 'Event without stream_id is invalid' do
      event = Event.new

      assert event.invalid?
      assert event.errors.has_key?(:stream_id)
      assert_error_message_translated(event, :stream_id, :blank)
    end

    test 'Event without aggregate_name is invalid' do
      event = Event.new

      assert event.invalid?
      assert event.errors.has_key?(:aggregate_name)
      assert_error_message_translated(event, :aggregate_name, :blank)
    end

    test 'Event without action is invalid' do
      event = Event.new

      assert event.invalid?
      assert event.errors.has_key?(:action)
      assert_error_message_translated(event, :action, :blank)
    end

    test 'Write model can save creation in events' do
      model = create_write_model

      assert_equal 1, Event.all.size
      event = Event.all.first
      assert_equal model.id, event.stream_id.to_i
      assert_equal 'WriteModel', event.aggregate_name
      assert_equal 'create', event.action
      assert_equal({ 'name'=>[nil, 'the_name'], 'is_valid'=>[nil, false], 'available_at'=>[nil, Time.zone.now.iso8601(3)] }, event.payload)
    end

    test 'Write model can save update in events' do
      model = create_write_model

      model.update!(name: 'the_new_name')

      assert_equal 2, Event.all.size
      event = Event.order(created_at: :desc).first
      assert_equal model.id, event.stream_id.to_i
      assert_equal 'WriteModel', event.aggregate_name
      assert_equal 'update', event.action
      assert_equal({'name' => ['the_name', 'the_new_name']}, event.payload)
    end

    test 'Write model can save destroy in events' do
      model = create_write_model

      model.destroy!

      assert_equal 2, Event.all.size
      event = Event.order(created_at: :desc).first
      assert_equal model.id, event.stream_id.to_i
      assert_equal 'WriteModel', event.aggregate_name
      assert_equal 'destroy', event.action
      assert_equal Hash.new, event.payload
    end

    test 'Write model can dispatch events' do
      model = create_write_model

      model.dispatch_event_log!('custom_action', 'the' => 'payload')

      assert_equal 2, Event.all.size
      event = Event.order(created_at: :desc).first
      assert_equal model.id, event.stream_id.to_i
      assert_equal 'WriteModel', event.aggregate_name
      assert_equal 'custom_action', event.action
      assert_equal({ 'the' => 'payload' }, event.payload)
    end

    test 'Read model can handle event' do
      create_write_model

      assert_equal 1, ReadModel.all.size
      model = ReadModel.all.first
      assert_equal 1, model.save_count
    end


    private

    def create_write_model(attributes = {})
      WriteModel.create!({ name: 'the_name', is_valid: false, available_at: Time.zone.now }.merge(attributes))
    end
  end
end
