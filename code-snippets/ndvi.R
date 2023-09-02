library('devtools')
#uncomment the scripts below when running
#for the first time
#install_github('barguzin/endow')
#remotes::install_github("wmgeolab/rgeoboundaries") # boundaries for countries

library(tidyverse)
library(MODIStsp)
# the list of data layters is aviable here: https://modis.gsfc.nasa.gov/data/dataprod/mod13.php
library(rgeoboundaries)
library(sf)
library(terra)
library(tmap)

# new test site from Elly's email: -19.883096, 21.081161
lat = -19.883096
lon = 21.081161
pt = endow::make_point(site_id = 'my_site', lon=lon, lat=lat)
pt_buff = endow::make_buffer(pt)

# Downloading the country boundary of Mongolia
map_boundary <- geoboundaries("Mongolia")
plot(st_geometry(map_boundary))

# Defining filepath to save downloaded spatial file
spatial_filepath <- "C:/Users/barguzin/Documents/VegetationData/mongolia.shp"

# Saving downloaded spatial file on to our computer
st_write(map_boundary, paste0(spatial_filepath))

#tmap_mode('plot')
tmap_mode('view')

tm_basemap(leaflet::providers$OpenStreetMap) +
  tm_view(set.view = c(lon, lat, 10)) +
  tm_shape(pt_buff) +
  tm_polygons(alpha=.25, col = 'blue') +
  tm_shape(pt) +
  tm_dots(size=.5, col='blue')

# create options file using gui

# get data
# --> Specify the path to a valid options file saved in advance from MODIStsp GUI
opts_file <- "C:/Users/barguzin/Documents/VegetationData/out_params.json"

# --> Launch the processing
MODIStsp(gui = FALSE, opts_file = opts_file)

