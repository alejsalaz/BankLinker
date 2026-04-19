default_envelopes = [
  { name: "Necesidades", color: "blue" },
  { name: "Comida",      color: "orange" },
  { name: "Compras",     color: "pink" },
  { name: "Salidas",     color: "purple" },
  { name: "Ropa",        color: "rose" },
  { name: "Ahorros",     color: "emerald" }
]

default_envelopes.each_with_index do |attrs, index|
  Envelope.find_or_create_by!(name: attrs[:name]) do |e|
    e.color = attrs[:color]
    e.position = index
  end
end

# Categorías sugeridas de Ivy Wallet. Son opcionales y el usuario puede editarlas.
default_ivy_categories = [
  "Alimentación",
  "Transporte",
  "Vivienda",
  "Servicios",
  "Entretenimiento",
  "Salud",
  "Ropa",
  "Ahorro",
  "Regalos",
  "Otros"
]

default_ivy_categories.each_with_index do |name, index|
  IvyCategory.find_or_create_by!(name: name) do |c|
    c.position = index
  end
end
