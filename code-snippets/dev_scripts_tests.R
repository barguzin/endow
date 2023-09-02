library(sf)
library(devtools)
install_github('barguzin/endow')
library(endow)
library(tmap)
library(tidyverse)

world_cities = st_read('C:/Users/barguzin/Downloads/World_Cities.csv',
             options=c("X_POSSIBLE_NAMES=X","Y_POSSIBLE_NAMES=Y"), crs=4326)

plot(st_geometry(world_cities))

usethis::use_data_raw("world_cities")


f = system.file('extdata', 'world_cities.csv', package='endow')

# 6.695016860965001, -1.6179580414855728
pt = endow::make_point(site_id='BB', lat=6.695016860965001, lon=-1.6179580414855728)

tmap_mode('view')
tm_shape(pt) +
  tm_dots()

# convert projection to meters

pt_m = st_transform(pt, 3857)
world_cities_m = st_transform(world_cities, 3857)

dist_m = st_distance(pt_m, world_cities_m, by_element = F)

gc_dist = st_distance(pt, world_cities, which='Great Circle')

dim(gc_dist)
m = gc_dist[,which.min(gc_dist)]
pos = which.min(gc_dist)
print(pos)

m = as.vector(m)

print(sum(world_cities$POP==0))
cnam = world_cities[pos, "CITY_NAME"]$CITY_NAME
cpop = world_cities[pos, "POP"]$POP

e <- tibble(
  SiteCode = "KK",
  dist_to_pop = m,
  #CityName = world_cities[pos, "CITY_NAME"]$CITY_NAME,
  CityName = ifelse(is.null(NULL), NA, cnam),
  CityPop = world_cities[pos, "POP"]$POP)


# testing funcs
library(endow)

data("dplace")

cities = system.file('extdata', 'world_cities.csv', package='endow')

f = get_dist_to_pop(cities_path = cities,
                    path_to_save = 'C:/Users/barguzin/Documents/',
                    site_id=dplace$SiteCode[3],
                    lon=dplace$lon[3], lat=dplace$lat[3],
                    var_name='dist_to_pop')
