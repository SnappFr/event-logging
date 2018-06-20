module EventLogging
  module Reader
    extend ActiveSupport::Concern

    included do
      class << self

        def register_write_models(*models)
          models.each do |model|
            model.add_read_model(self.name)
          end
        end
      end
    end
  end
end
