#' Collector
#'
#' The function collects the data give an input raster and a coordinate.
#'
#' @param raster_path (char) a path to an input raster to be processed
#' @param path_to_save (char) a directory to store the processed rasters
#' @param ... other arguments from endow.utils functions
#'
#' @return None. Saves clipped rasters and processed csv files to /processed.
#' @export
#'
#' @examples
#'# Kumasi coordinates: 6.695016860965001, -1.6179580414855728
#'rast_path = system.file("extdata", "africa_cropland_netgain.tif", package="endow")
#'f = night_collector(rast_path, '/my_folder/', site_id='AH', lon=-1.62, lat=6.7, dist=6000, var_name='cropland')
night_collector <- function(raster_path, path_to_save, ...) {

  r = terra::rast(raster_path)

  d = list(...)

  # generate a point for a site
  pt = make_point(d$site_id, d$lon, d$lat)

  # create a buffer within specified distance
  coords_buffer = make_buffer(pt, dist=d$dist)

  # crop a raster to the buffer
  cropped_raster = terra::crop(r, coords_buffer)

  # check for empty raster (usually coordinates over ocean)
  c = terra::global(cropped_raster, fun=mean, na.rm=T)$mean

  if (is.nan(c)){print('empty raster returned after cropping')}

  # save clipped raster
  vdir = paste0(path_to_save, d$site_id, '/', d$var_name, '/')
  print(paste('creating directory in', vdir))
  dir.create(vdir, recursive = T)
  terra::writeRaster(cropped_raster, paste0(vdir, d$site_id, '_', d$var_name,'.tif'), overwrite=T)

  # save csv

  return(vdir)
}
