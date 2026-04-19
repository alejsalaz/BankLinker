module Extractors
  class RappiPay < Base
    DATE_REGEX = /(\d{1,2}[\/\-]\d{1,2}[\/\-]\d{2,4}|\d{4}[\/\-]\d{1,2}[\/\-]\d{1,2})/
    AMOUNT_REGEX = /(-?\$?\s?(?:\d{1,3}(?:[.,]\d{3})+(?:[.,]\d{1,2})?|\d+(?:[.,]\d{1,2})?))(?!\d)/

    MONTH_NAMES = {
      "ene" => 1, "feb" => 2, "mar" => 3, "abr" => 4, "may" => 5, "jun" => 6,
      "jul" => 7, "ago" => 8, "sep" => 9, "oct" => 10, "nov" => 11, "dic" => 12
    }.freeze

    def call
      text = read_text
      return [] if text.blank?

      text.each_line.filter_map { |line| parse_line(line) }
    end

    private

    def parse_line(line)
      cleaned = line.to_s.strip
      return nil if cleaned.empty?

      date = extract_date(cleaned)
      amount = extract_amount(cleaned)
      return nil unless date && amount

      description = extract_description(cleaned, date_match: date[:match], amount_match: amount[:match])
      return nil if description.blank?

      {
        date: date[:value],
        description: description,
        amount: amount[:value]
      }
    end

    def extract_date(line)
      match = line.match(DATE_REGEX)
      return nil unless match

      raw = match[1]
      parts = raw.split(/[\/\-]/)
      value = parse_date_parts(parts)
      return nil unless value

      { value: value, match: raw }
    rescue ArgumentError
      nil
    end

    def parse_date_parts(parts)
      if parts.first.length == 4
        year, month, day = parts.map(&:to_i)
      else
        day, month, year = parts.map(&:to_i)
        year += 2000 if year < 100
      end

      Date.new(year, month, day)
    rescue Date::Error, ArgumentError
      nil
    end

    def extract_amount(line)
      candidates = line.to_enum(:scan, AMOUNT_REGEX).map { Regexp.last_match }
      return nil if candidates.empty?

      match = candidates.last
      raw = match[1]
      numeric = normalize_amount(raw)
      return nil unless numeric

      { value: numeric, match: raw }
    end

    def normalize_amount(raw)
      cleaned = raw.gsub(/[\s\$]/, "")
      negative = cleaned.start_with?("-")
      cleaned = cleaned.delete_prefix("-")

      last_dot = cleaned.rindex(".")
      last_comma = cleaned.rindex(",")

      normalized =
        if last_dot && last_comma
          if last_comma > last_dot
            cleaned.delete(".").tr(",", ".")
          else
            cleaned.delete(",")
          end
        elsif last_comma
          if cleaned.count(",") > 1 || (cleaned.length - last_comma - 1) == 3
            cleaned.delete(",")
          else
            cleaned.tr(",", ".")
          end
        elsif last_dot
          if cleaned.count(".") > 1 || (cleaned.length - last_dot - 1) == 3
            cleaned.delete(".")
          else
            cleaned
          end
        else
          cleaned
        end

      value = BigDecimal(normalized)
      negative ? -value : value
    rescue ArgumentError, TypeError
      nil
    end

    def extract_description(line, date_match:, amount_match:)
      cleaned = line.dup
      cleaned.sub!(date_match, "")
      cleaned.sub!(amount_match, "")
      cleaned.gsub(/\s+/, " ").strip.delete_suffix("$").strip
    end
  end
end
