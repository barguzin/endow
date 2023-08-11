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



#tmap_mode('plot')
tmap_mode('view')

tm_basemap(leaflet::providers$OpenStreetMap) +
  tm_view(set.view = c(lon, lat, 10)) +
  tm_shape(pt_buff) +
  tm_polygons(alpha=.25, col = 'blue') +
  tm_shape(pt) +
  tm_dots(size=.5, col='blue')

