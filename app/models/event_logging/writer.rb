module EventLogging
  module Writer
    extend ActiveSupport::Concern

    included do
      after_create :event_logging_create_event
      after_update :event_logging_update_event
      before_destroy :event_logging_destroy_event

      class << self
        def add_read_model(model)
          EventLogging::Mapping.instance.add(self.name, model)
        end
      end
    end

    def dispatch_event_log!(action, payload)
      save_event_logging_event(action, payload)
    end

    private

    def event_logging_create_event
      save_event_logging_event(:create)
    end

    def event_logging_update_event
      save_event_logging_event(:update)
    end

    def event_logging_destroy_event
      save_event_logging_event(:destroy, {})
    end

    def save_event_logging_event(action, payload = nil)
      event = Event.generate!(self, action, payload)
      Mapping.instance.readers(self.class.name).each do |model|
        model.constantize.handle_event_log(event)
      end
    end
  end
end
