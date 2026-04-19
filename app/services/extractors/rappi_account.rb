module Extractors
  # Parser para el extracto de RappiCuenta (cuenta de ahorros RappiPay).
  # Cada movimiento viene con este layout:
  #
  #   DD mmm YYYY   DESCRIPCIÓN   -?$MONTO
  #
  # Donde el mes es abreviado en español (Ene, Feb, Mar, Abr, May, Jun, Jul, Ago, Sep, Oct, Nov, Dic)
  # y el monto usa formato anglo (coma para miles, punto para decimales).
  class RappiAccount < Base
    SPANISH_MONTHS = {
      "ene" => 1, "feb" => 2, "mar" => 3, "abr" => 4,
      "may" => 5, "jun" => 6, "jul" => 7, "ago" => 8,
      "sep" => 9, "oct" => 10, "nov" => 11, "dic" => 12
    }.freeze

    LINE_REGEX = /
      ^\s*
      (?<day>\d{1,2})\s+
      (?<month>[A-Za-zñÑ]{3})\s+
      (?<year>\d{4})\s+
      (?<description>.+?)\s{2,}
      (?<amount>-?\$[\d,.]+)
      \s*$
    /x

    def call
      text = read_text
      return [] if text.blank?

      text.each_line.filter_map { |line| parse_line(line) }
    end

    private

    def parse_line(line)
      match = line.match(LINE_REGEX)
      return nil unless match

      date = parse_spanish_date(match[:day], match[:month], match[:year])
      amount = normalize_anglo_amount(match[:amount])
      description = match[:description].strip
      return nil if date.nil? || amount.nil? || description.empty?

      {
        date: date,
        description: description,
        amount: amount
      }
    end

    def parse_spanish_date(day, month_abbr, year)
      month = SPANISH_MONTHS[month_abbr.downcase[0, 3]]
      return nil unless month

      Date.new(year.to_i, month, day.to_i)
    rescue Date::Error, ArgumentError
      nil
    end

    # "-$32,500.00" → -32500.00 (formato anglo: , miles, . decimal)
    def normalize_anglo_amount(raw)
      cleaned = raw.to_s.delete("$").delete(",")
      BigDecimal(cleaned)
    rescue ArgumentError, TypeError
      nil
    end
  end
end
