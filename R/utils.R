# write a function to create an sf feature collection
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
