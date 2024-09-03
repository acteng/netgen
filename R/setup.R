# Aim: generate input data for od2net with R

make_zones = function(file = "https://raw.githubusercontent.com/nptscot/npt/main/data-raw/zones_edinburgh.geojson") {
  zones = sf::read_sf(file)[1]
  names(zones)[1] = "name"
  sf::write_sf(zones, "input/zones.geojson", delete_dsn = TRUE)
}

getbbox_from_zones = function() {
  zones = sf::st_read("input/zones.geojson")
  bbox = sf::st_bbox(zones)
  paste0(bbox, collapse = ",")
}

make_osm = function() {
  # TODO: use osmextract to download the file?
  if (!file.exists("input/input.pbf")) {
    download.file(
      url = "https://download.geofabrik.de/europe/great-britain/scotland-latest.osm.pbf",
      destfile = "input/input-all.osm.pbf"
    )
  }
  # Clip to Lisbon:
  # TODO: use bbox from input/zones.geojson
  bb = getbbox_from_zones()
  msg = paste0("osmium extract -b ", bb, " input/input-all.osm.pbf -o input/input.osm.pbf --overwrite")
  system(msg)
}

# make_elevation = function() {
#     # Check you're in the right working directory and if not cd
#     check_and_change_directory("examples/lisbon")
#     # Download the file
#     if (!file.exists("input/LisboaIST_10m_4326.tif")) {
#       download.file(
#           url = "https://assets.od2net.org/input/LisboaIST_10m_4326.tif",
#           destfile = "input/LisboaIST_10m_4326.tif"
#       )
#     }
# }

make_origins = function() {
  buildings = sf::read_sf("input/input.osm.pbf", query = "SELECT osm_id FROM multipolygons WHERE building IS NOT NULL")
  centroids = sf::st_centroid(buildings)
  sf::write_sf(centroids, "input/buildings.geojson", delete_dsn = TRUE)
}

make_od = function() {
  od = readr::read_csv("https://raw.githubusercontent.com/nptscot/npt/main/data-raw/od_subset.csv")
  od = od |>
    dplyr::transmute(from = geo_code1, to = geo_code2, count = bicycle)
  readr::write_csv(od, "input/od.csv")
}

main = function() {
  dir.create("input", showWarnings = FALSE)
  make_zones()
  make_osm()
  # make_elevation()
  make_origins()
  make_od()
}
