module Extractors
  # Parser para el extracto de RappiCard (tarjeta de crédito Davivienda).
  # Cada movimiento llega en una línea con este layout aproximado:
  #
  #   Fisica|Virtual  YYYY-MM-DD  DESCRIPCIÓN  $MONTO_ORIG  $CUOTA  N de M  $SALDO  TASA%  TASA%
  #
  # A veces la descripción viene partida en las líneas adyacentes cuando es
  # muy larga (ej: "MERCADO / PAGO*MERCADOLI"). En esos casos la línea con
  # fecha solo tiene montos, y hay que armar la descripción mirando arriba y abajo.
  class RappiCard < Base
    MONTH_LINE_REGEX = /
      ^\s*
      (?<type>Fisica|Virtual)\s+
      (?<date>\d{4}-\d{2}-\d{2})\s+
      (?<rest>.+)$
    /x

    AMOUNT_REGEX = /\$([\d\.,]+)/
    SUMMARY_KEYWORDS = /\b(saldo\s+anterior|saldo\s+final|intereses|cupo\s+utilizado|cupo\s+total|pago\s+m[ií]nimo|pago\s+total|pago\s+alternativo|total\s+a\s+pagar)\b/i

    def call
      text = read_text
      return [] if text.blank?

      @lines = text.each_line.map(&:chomp)
      @lines.each_with_index.filter_map { |line, i| parse_line(line, i) }
    end

    private

    def parse_line(line, index)
      match = line.match(MONTH_LINE_REGEX)
      return nil unless match

      rest = match[:rest]
      amounts = rest.to_enum(:scan, AMOUNT_REGEX).map { Regexp.last_match(1) }
      return nil if amounts.empty?

      amount = normalize_colombian_amount(amounts.first)
      date = parse_iso_date(match[:date])
      return nil if amount.nil? || date.nil?

      description = extract_description(rest, amounts.first) || neighbour_description(index)
      return nil if description.blank?
      return nil if description.match?(SUMMARY_KEYWORDS)

      {
        date: date,
        description: description,
        amount: amount
      }
    end

    def extract_description(rest, first_amount)
      before_amount = rest.split("$#{first_amount}", 2).first.to_s.strip
      return nil if before_amount.empty? || before_amount.start_with?("$")

      before_amount
    end

    # Las descripciones partidas viven en la línea anterior y/o siguiente,
    # con muchos espacios al inicio y sin fecha ni montos.
    def neighbour_description(index)
      prev_line = clean_neighbour(@lines[index - 1]) if index.positive?
      next_line = clean_neighbour(@lines[index + 1])

      [prev_line, next_line].compact.reject(&:empty?).join(" ").strip.presence
    end

    def clean_neighbour(line)
      return nil if line.blank?
      stripped = line.strip
      return nil if stripped.empty?
      return nil if stripped.match?(MONTH_LINE_REGEX)
      return nil if stripped.match?(AMOUNT_REGEX)
      return nil if stripped.match?(/\A\d{4}-\d{2}-\d{2}/)

      stripped
    end

    def parse_iso_date(raw)
      Date.iso8601(raw)
    rescue Date::Error, ArgumentError
      nil
    end

    # "45.600,00" → 45600.00 (formato colombiano: . miles, , decimal)
    def normalize_colombian_amount(raw)
      cleaned = raw.to_s.gsub(".", "").tr(",", ".")
      BigDecimal(cleaned)
    rescue ArgumentError, TypeError
      nil
    end
  end
end
