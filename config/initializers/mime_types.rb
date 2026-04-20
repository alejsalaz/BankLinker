# Mime types extra para la PWA.
# Chrome acepta manifest aunque venga como text/plain, pero es buena idea
# servirlo como application/manifest+json para cumplir con la spec W3C.
Mime::Type.register "application/manifest+json", :webmanifest

# Rack sirve los archivos de public/ usando su propia tabla de mimes, por lo
# que registramos la extensión ahí también para que el manifest viaje con el
# Content-Type correcto.
Rack::Mime::MIME_TYPES[".webmanifest"] = "application/manifest+json"
