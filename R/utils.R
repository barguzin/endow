#' Make Point
#'
#' @param site_id (id variable associated with a geographic point)
#' @param lon (longitude in decimal degrees)
#' @param lat (latitude in decimal degrees)
#'
#' @return a simple geometry feature
#' @export
#'
#' @examples
#' x = 45
#' y = 45
#' my_id = 'MM'
#' make_point(my_id, x, y)
make_point <- function(site_id, lon, lat) {
  geom = sf::st_sfc(sf::st_point(c(lon, lat)))
  my_sf = sf::st_sf(id_var = site_id, geom, crs='epsg:4326')
  return(my_sf)
}

#' Make Buffer
#'
#' @param sf_obj a simple feature dataframe
#' @param dist (int) distance in meters to draw a buffer around
#'
#' @return buffer of an sf_obj
#' @export
#'
#' @examples
#' pts = make_point("my_site", 45, 45)
#' pts_buff = make_buffer(pts, 5000)
make_buffer <- function(sf_obj, dist=5000) {
  coords_buffer = sf_obj %>%
    sf::st_transform('epsg:3857') %>%
    sf::st_buffer(dist) %>%
    sf::st_transform('epsg:4326')
  return(coords_buffer)
}


#' Extract Raster
#'
#' @param rast - raster object (use terra)
#' @param clip_vec - vector (typically an sf data.frame)
#' @param var_name - char (variable name for summary purposes)
#' @param dist - int (distance in meters which was used for a buffer)
#' @param func_name - function to summarize extracted values (default=MEAN)
#'
#' @return dataframe with summarized values
#' @export
#'
#' @examples
#' pts = make_point("my_site", 45, 45)
#' pts_buff = make_buffer(pts, 5000)
#' fpath = system.file("extdata", "africa_cropland_netgain.tif", package="endow")
#' r = terra::rast(fpath)
#' e = extract_raster(r, pts_buff, var_name='my_variable', dist=5000)
extract_raster <- function(rast, clip_vec, var_name, dist, func_name=mean) {
  e = terra::extract(rast, clip_vec, var_name, fun=func_name, na.rm=T)
  colnames(e) <- c('id_var', var_name)
  e$dist <- dist
  return(e)
}

#' Generate directories for data
#'
#' This script should only be run once to generate a separate directory per each site.
#'
#'--- dir_to_save /
#'                --- site_A /
#'                --- site_B /
#'
#' @param dir_to_save (char) path to save data onto
#' @param site_id (char) name of variable with identifier of a site
#' @param var_name (char) variable name (aka souce, e.g. 'night_light')
#'
#' @return dir_name (directory path)
#' @export
#'
#' @examples
#' generate_filedirs('/my/new/folder/', site_id='AH', var_name='var_of_interest')
generate_filedirs <- function(dir_to_save, site_id, var_name) {
  dir_name = paste0(dir_to_save, site_id, '/', var_name, '/')
  print(dir_name)
  dir.create(dir_name, recursive=T)
  return(dir_name)
}


#' Expand radius
#'
#' For data with patchy / sparse coverage iteratively increase buffer
#' distance, until the ratio of non-null values hits the threshhold
#'
#' @param stars_obj description
#' @param cropped_stars cropped stars object (sf)
#' @param attr_name attribute name for which sparsity is considered (char)
#' @param dist distance in meters
#' @param na_ratio ratio of NA values (0, 1)
#' @param step_size step size in meters
#' @param pnt an sf object with point geometry (build from site coords)
#'
#' @return cropped raster/ncdf
#' @export
#'
#' @examples
#'
#' lng = -1.62
#' lat = 6.7
#' dist = 5000
#' ss_id = 'KI'
#'
#' pnt = make_point(lon = lng, lat = lat, site_id=ss_id)
#' buff = make_buffer(pnt, dist)
#'
#' ncdf_path = system.file("extdata", "world_soil_moisture_jan2016.nc",
#'  package="endow")
#'
#' s = stars::read_stars(ncdf_path)
#'
#' s = sf::st_set_crs(s, 'EPSG:4326')
#'
#' c = expand_radius(s, s[buff], attr_name='sm', dist=dist, na_ratio=.5,
#'  step_size=5000, pnt=pnt)
#'
expand_radius <- function(stars_obj, cropped_stars, attr_name, dist, na_ratio=.5,
                          step_size=5000, pnt) {

  d = dist
  start_na_ratio = sum(is.na(cropped_stars[[attr_name]]))/length(cropped_stars[[attr_name]])

  while (start_na_ratio>na_ratio & d<100000) {

    d = dist + step_size

    new_buff = make_buffer(pnt, d)

    clipper = stars_obj[new_buff]

    start_na_ratio = sum(is.na(clipper[[attr_name]]))/length(clipper[[attr_name]])

  }

  return(clipper)

}
