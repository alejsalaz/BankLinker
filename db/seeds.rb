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
