#' Make Point
#'
#' @param idvar (id variable associated with a geographic point)
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
make_point <- function(idvar, lon, lat) {
  geom = sf::st_sfc(sf::st_point(c(lon, lat)))
  my_sf = sf::st_sf(id_var = idvar, geom, crs='epsg:4326')
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
#' e = extract_raster(r, pts_buff)
extract_raster <- function(rast, clip_vec, func_name=mean) {
  e = terra::extract(rast, clip_vec, fun=func_name, na.rm=T)
  return(e)
}
