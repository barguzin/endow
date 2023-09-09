#' Calculates distance to population center
#
#' @param path_to_save (char) a path to save procesed data
#' @param ...
#'
#' @return None. Saves files to the 'processed' directory.
#' @export
#'
#' @examples
#'# Kumasi coordinates: 6.695016860965001, -1.6179580414855728
#'pp = system.file('extdata', 'world_cities.csv', package='endow')
#'
#'f = get_dist_to_pop(pp, '/my_folder/',
#'  site_id='KU',
#'  lon=-1.62, lat=6.7,
#'  var_name='cropland')
#'
get_osm_road_length <- function(path_to_save, ...) {

  d = list(...)

  # generate a point for a site
  buff = make_buffer(make_point(d$site_id, d$lon, d$lat))

  # download osm data for a buffer
  bb = st_bbox(buff)

  hwy = bb %>%
    opq() %>%
    add_osm_feature(key = 'highway') %>%
    osmdata_sf()

  # get the lines out
  lines = hwy$osm_lines

  # calculate dist
  if (dim(lines)[1]==0) {
    sum_dist = 0
  } else {
  sum_dist = as.vector(sum(st_length(lines),na.rm=T))
}
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
    fdir_csv = paste0(vdir, d$site_id, '_', d$var_name, '_', d$dist, 'm', '.csv')
  } else {
    fdir_csv = paste0(vdir, d$site_id, '_', d$var_name, '_', d$dist, 'm', '_', year, '.csv')
  }

  # create a dataframe to be saved
  e <- tibble::tibble(
      SiteCode = 0,
      val = sum_dist,
      dist = d$dist) # for non-buffer based metrics

  readr::write_csv(e, fdir_csv, col_names=F)

}
