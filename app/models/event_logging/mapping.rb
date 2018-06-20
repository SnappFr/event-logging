module EventLogging
  class Mapping
    include Singleton

    def initialize
      @mapping = {}
    end

    def add(writer, reader)
      @mapping[writer] ||= []
      @mapping[writer] << reader
    end

    def readers(writer)
      @mapping[writer] || []
    end
  end
end
