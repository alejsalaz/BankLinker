default_pockets = [
  { name: "Necesidades", color: "blue" },
  { name: "Comida",      color: "orange" },
  { name: "Compras",     color: "pink" },
  { name: "Salidas",     color: "purple" },
  { name: "Ropa",        color: "rose" },
  { name: "Ahorros",     color: "emerald" }
]

default_pockets.each_with_index do |attrs, index|
  Pocket.find_or_create_by!(name: attrs[:name]) do |p|
    p.color = attrs[:color]
    p.position = index
  end
end
