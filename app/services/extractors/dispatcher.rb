module Extractors
  class Dispatcher
    EXTRACTORS = {
      rappi_card: Extractors::RappiCard,
      rappi_account: Extractors::RappiAccount
    }.freeze

    DEFAULT = :rappi_card

    def self.for(path, type: DEFAULT, password: nil)
      klass = EXTRACTORS[type.to_sym] || EXTRACTORS[DEFAULT]
      klass.new(path, password: password)
    end

    def self.available_types
      EXTRACTORS.keys
    end
  end
end
