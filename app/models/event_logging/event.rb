module EventLogging
  class Event < ApplicationRecord

    validates :aggregate_name, presence: true
    validates :stream_id, presence: true
    validates :action, presence: true

    class << self
      def generate!(model, action, payload)
        if payload.nil?
          if defined?(model.saved_changes) && action != :destroy
            payload = model.saved_changes.except('id')
          end
        end
        create!(aggregate_name: model.class.name, stream_id: model.id, action: action, payload: payload)
      end
    end
  end
end
