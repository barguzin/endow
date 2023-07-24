#' Collector
#'
#' The function collects the data give an input raster and a coordinate.
#'
#' @param raster_path (char) a path to an input raster to be processed
#' @param path_to_save (char) a directory to store the processed rasters
#' @param year (int) for year-specific data, input a year for a raster file
#' @param year_var date variable associated with each site
#' @param FUN function to pass for summary
#' @param ... other arguments from endow.utils functions
#'
#' @return None. Saves clipped rasters and processed csv files to /processed.
#' @export
#'
#' @examples
#'# Kumasi coordinates: 6.695016860965001, -1.6179580414855728
#'rast_path = system.file("extdata", "africa_cropland_netgain.tif",
#'  package="endow")
#'f = collector(rast_path, '/my_folder/', year=2017,
#'  year_var=as.POSIXct('2020-01-01 14:45:18',
#'  format="%Y-%m-%d %H:%M:%S",tz="UTC"),
#'  site_id='KU',
#'  FUN='sum',
#'  lon=-1.62, lat=6.7, dist=6000, var_name='cropland')
collector <- function(raster_path, path_to_save, year=NULL, year_var=NULL, FUN=mean, ...) {

  if (!missing(year_var)) {
    y = lubridate::year(year_var)

    if (is.na(y)) {
      print('No year specified in Wave 1 Start variable. Consider adding.')
    }
    else if (y!=year) {
      print('supplied year and Wave 1 Start year are not equal!')
    }

  }

  r = terra::rast(raster_path)

  # check for projection and reproject
  if (terra::crs(r, describe=T, proj=T)$code[1] != "4326") {
    r = terra::project(r, "EPSG:4326")
  } else {print('raster is in EPSG:4326 crs')}

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
  if (missing(year)) {
    print('No year supplied to function.')
    vdir = paste0(path_to_save, d$site_id, '/', d$var_name, '/')
  } else {
    print('non missing year')
    vdir = paste0(path_to_save, d$site_id, '/', d$var_name, '/', year, '/')
  }

  print(paste('creating directory in', vdir))
  dir.create(vdir, recursive = T)

  if (missing(year)) {
    fdir = paste0(vdir, d$site_id, '_', d$var_name, '_', d$dist, 'm', '.tif')
  } else {
    fdir = paste0(vdir, d$site_id, '_', d$var_name, '_', d$dist, 'm', '_', year, '.tif')
  }

  print(paste('saving raster to', fdir))
  terra::writeRaster(cropped_raster, fdir, overwrite=T)


  # extract summary statistics
  #e = extract_raster(r, coords_buffer, var_name=d$var_name, dist=d$dist, FUN=FUN)

  FUN <- match.fun(FUN)
  e = terra::extract(r, coords_buffer, d$var_name, fun=FUN, na.rm=T)
  colnames(e) <- c('id_var', d$var_name)
  e$dist <- d$dist

  if (missing(year)) {
    fdir_csv = paste0(vdir, d$site_id, '_', d$var_name, '_', d$dist, 'm', '.csv')
  } else {
    fdir_csv = paste0(vdir, d$site_id, '_', d$var_name, '_', d$dist, 'm', '_', year, '.csv')
  }

  # save csv
  readr::write_csv(e, fdir_csv, col_names = F)

  #return(vdir)
}
