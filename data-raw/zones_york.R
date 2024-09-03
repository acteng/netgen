## code to prepare `zones_york` dataset goes here

if (!file.exists("lsoas_2021.geojson")) {

lsoas_2021 = sf::read_sf("https://services1.arcgis.com/ESMARspQHYMw9BZ9/arcgis/rest/services/Lower_layer_Super_Output_Areas_December_2021_Boundaries_EW_BSC_V4/FeatureServer/0/query?outFields=*&where=1%3D1&f=geojson")
sf::write_sf(lsoas_2021, "lsoas_2021.geojson")

}
lsoas_2021 = sf::read_sf("lsoas_2021.geojson") |>
  select(LSOA21CD, LSOA21NM) 
# names(lsoas_2021)
zones_york = lsoas_2021 |>
  filter(str_detect(LSOA21NM, "^York")) 

# Population in each zone:
u_xls = "https://www.ons.gov.uk/file?uri=/peoplepopulationandcommunity/populationandmigration/populationestimates/datasets/lowersuperoutputareamidyearpopulationestimatesnationalstatistics/mid2021andmid2022/sapelsoabroadagetablefinal.xlsx"

if (!file.exists("sapelsoabroadagetablefinal.xlsx")) {
  download.file(u_xls, "sapelsoabroadagetablefinal.xlsx")
}

lsoa_populations = readxl::read_excel("sapelsoabroadagetablefinal.xlsx", sheet = 6, skip = 3)
names(lsoa_populations)
#  [1] "LAD 2021 Code"  "LAD 2021 Name"  "LSOA 2021 Code" "LSOA 2021 Name"
#  [5] "Total"          "F0 to 15"       "F16 to 29"      "F30 to 44"     
#  [9] "F45 to 64"      "F65 and over"   "M0 to 15"       "M16 to 29"     
# [13] "M30 to 44"      "M45 to 64"      "M65 and over"  

summary(zones_york$LSOA21CD %in% lsoa_populations$`LSOA 2021 Code`)
# all are in there!
# Add 0-15 to zones_york
lsoa_populations_to_join = lsoa_populations |>
  select(-`LAD 2021 Code`, -`LAD 2021 Name`, -`LSOA 2021 Name`) |>
  janitor::clean_names()  |>
  rename(
    LSOA21CD = `lsoa_2021_code`
  )

zones_york = left_join(
  zones_york,
  lsoa_populations_to_join
)
zones_york = sf::st_sf(
  sf::st_drop_geometry(zones_york),
  geometry = zones_york$geometry
)

names(zones_york)

usethis::use_data(zones_york, overwrite = TRUE)


destinations_york = destinations_york |>
  filter(!is.na(n_pupils))

usethis::use_data(destinations_york, overwrite = TRUE)

# Save to input folder
sf::write_sf(zones_york, "input/zones_york.geojson")
