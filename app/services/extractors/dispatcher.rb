module Extractors
  class Dispatcher
    EXTRACTORS = {
      rappi_pay: Extractors::RappiPay
    }.freeze

    DEFAULT = :rappi_pay

    def self.for(path, type: DEFAULT, password: nil)
      klass = EXTRACTORS[type.to_sym] || EXTRACTORS[DEFAULT]
      klass.new(path, password: password)
    end

    def self.available_types
      EXTRACTORS.keys
    end
  end
end
