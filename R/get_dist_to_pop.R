#' Calculates distance to population center
#'
#' @param cities_path (char) a path to file with cities
#' @param path_to_save (char) a path to save processed data
#' @param stat (char) type of stat (dist - distance to city, pop - population in city)
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
get_dist_to_pop <- function(cities_path, path_to_save, stat='dist', ...) {

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

  cn = wc[pos, "CITY_NAME"]$CITY_NAME
  print(paste('city name is', cn))
  print(typeof(cn))
  print(length(cn))

  cp = wc[pos, "POP"]$POP
  print(paste('city population is', cp))
  print(typeof(cp))
  print(length(cp))

  # create a dataframe to be saved
  if (stat=='dist') {
    e <- tibble::tibble(
      SiteCode = 0,
      val = min_dist,
      dist = -9999) # for non-buffer based metrics
  } else if (stat=='pop') {
    e <- tibble::tibble(
      SiteCode = 0,
      val = paste(cp),
      dist = -9999) # for non-buffer based metrics
  }

  # create a dataframe to be saved
  # e <- tibble::tibble(
  #   SiteCode = d$site_id,
  #   DistancePop = min_dist,
  #   CityName = paste(cn), #ifelse(is.null(cn), NA, cn),
  #   CityPop = paste(cp)) #ifelse(is.null(cp), NA, cp))

  #print(paste(dim(e)))
  #e$CityName = as.character(cn)
  #e$CityPop = as.numeric(cp)

  #colnames(e) = c('SiteCode', 'DistancePop', 'CityName', 'CityPop')

  readr::write_csv(e, fdir_csv, col_names=F)

}
