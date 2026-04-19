module Extractors
  class Base
    IMAGE_EXTENSIONS = %w[.png .jpg .jpeg .webp .tiff .tif .bmp].freeze

    def initialize(path, password: nil)
      @path = path.to_s
      @password = password.presence
    end

    def call
      raise NotImplementedError, "#{self.class} must implement #call and return Array<Hash>"
    end

    private

    attr_reader :path, :password

    def extension
      File.extname(path).downcase
    end

    def pdf?
      extension == ".pdf"
    end

    def image?
      IMAGE_EXTENSIONS.include?(extension)
    end

    def read_text
      if pdf?
        read_pdf_text
      elsif image?
        read_image_text
      else
        raise ArgumentError, "Formato no soportado: #{extension.inspect}"
      end
    end

    def read_pdf_text
      require "pdf-reader"

      reader_options = { password: password }.compact
      reader = PDF::Reader.new(path, **reader_options)
      reader.pages.map(&:text).join("\n")
    rescue PDF::Reader::EncryptedPDFError => e
      raise "El PDF está protegido y requiere contraseña (#{e.message})"
    rescue PDF::Reader::MalformedPDFError => e
      raise "No se pudo leer el PDF (#{e.message}). ¿La contraseña es correcta?"
    end

    def read_image_text
      require "rtesseract"

      RTesseract.new(path, lang: "spa+eng").to_s
    rescue LoadError, StandardError => e
      raise "No se pudo leer la imagen con OCR (#{e.class}: #{e.message}). ¿Está instalado tesseract-ocr?"
    end
  end
end
