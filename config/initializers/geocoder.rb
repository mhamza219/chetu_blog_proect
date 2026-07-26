Geocoder.configure(
  # Geocoding options
  timeout: 5,                  # geocoding service timeout (secs)
  lookup: :nominatim,          # name of geocoding service (symbol)
  ip_lookup: :ipinfo_io,       # name of IP address geocoding service (symbol)
  language: :en,               # ISO-639 language code
  use_https: true,             # use HTTPS for lookup requests?
  headers: { 'User-Agent' => 'ChetuBlogApp/1.0' }, # Custom User-Agent header required by Nominatim

  # Calculation options
  units: :km,                  # :km for kilometers or :mi for miles
  distances: :linear           # :spherical or :linear
)
