#' Calculates distance to population center
#'
#' @param cities_path (char) a path to file with cities
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
#'f = get_dist_to_pop(pp, '/my_folder/', year=2017,
#'  year_var=as.POSIXct('2020-01-01 14:45:18',
#'  format="%Y-%m-%d %H:%M:%S",tz="UTC"),
#'  site_id='KU',
#'  FUN='sum',
#'  lon=-1.62, lat=6.7,
#'  var_name='cropland')
#'
get_dist_to_pop <- function(cities_path, path_to_save, ...) {

  d = list(...)

  # generate a point for a site
  pt = make_point(d$site_id, d$lon, d$lat)

  # read in cities data with coordinates
  wc = sf::st_read(cities_path,
               options=c("X_POSSIBLE_NAMES=X","Y_POSSIBLE_NAMES=Y"),
               crs=4326)

  gc_dist = sf::st_distance(pt, wc, which='Great Circle')

  min_dist = as.vector(gc_dist[,which.min(gc_dist)])
  pos = which.min(gc_dist)

  vdir = paste0(path_to_save, d$site_id, '/', d$var_name, '/')

  print(paste('creating directory in', vdir))
  dir.create(vdir, recursive = T)

  fdir_csv = paste0(vdir, d$site_id, '_', d$var_name, '_', 'm', '.csv')

  # create a dataframe to be saved
  e <- data.frame(
    SiteCode = d$site_id,
    DistancePop = min_dist,
    CityName = wc[pos, "CITY_NAME"]$CITY_NAME,
    CityPop = wc[pos, "POP"]$POP)

  #colnames(e) = c('SiteCode', 'DistancePop', 'CityName', 'CityPop')

  readr::write_csv(e, fdir_csv)

}
