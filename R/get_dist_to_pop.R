#' Title
#'
#' @param cities_path
#' @param path_to_save
#' @param ...
#'
#' @return None. Saves files to the 'processed' directory.
#' @export
#'
#' @examples
get_dist_to_pop <- function(cities_path, path_to_save, ...) {

  d = list(...)

  # generate a point for a site
  pt = make_point(d$site_id, d$lon, d$lat)

  # create a buffer within specified distance
  coords_buffer = make_buffer(pt, dist=d$dist)

  # read in cities data with coordinates
  df = st_read(cities_path,
               options=c("X_POSSIBLE_NAMES=X","Y_POSSIBLE_NAMES=Y"))

}
