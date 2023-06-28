library(terra)

# create a directory for raw data
dir.create('inst/extdata/', recursive = T)

# save file
url = 'https://glad.geog.umd.edu/Potapov/Global_Crop/Data/Global_cropland_3km_netgain.tif'

#download.file(url=url, destfile = 'inst/extdata/Global_cropland_3km_netgain.tif')

# read the file from URL
r = terra::rast(url)

# africa bbox can be acquired with a tool from
# https://boundingbox.klokantech.com/
wkt = "POLYGON((-17.8 37.7, 52.9 37.7, 52.9 -34.6, -17.8 -34.6, -17.8 37.7))"
af = data.frame(Africa = 'Africa')

af$geom = wkt
af = st_as_sf(af, wkt = "geom")

af_raster = terra::crop(r, af)

terra::writeRaster(af_raster,
                   'inst/extdata/africa_cropland_netgain.tif', overwrite=T)
