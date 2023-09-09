#' Calculates distance to population center
#'
#' @param df (data frame) a dataframe downloaded from opencellid
#' @param path_to_save (char) a path to save procesed data
#' @param k (int) k for the number of neighbors
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
get_dist_to_cell <- function(df, path_to_save, k=10, ...) {

  d = list(...)

  # generate a point for a site
  p = dplyr::as_tibble(cbind(d$lon, d$lat))

  # find knn
  ns = FNN::get.knnx(data=df, query=p, k=k, algorithm=c("kd_tree"))

  # get coordinates of nbrs
  pts = df[ns$nn.index[1,],]

  # convert to sf for dist calculations
  pts_geo = sf::st_as_sf(pts, coords=c("lon", "lat"), crs=4326)
  marker = sf::st_as_sf(p, coords=c("lon", "lat"), crs=4326)

  avg_dist = as.vector(mean(sf::st_distance(pts_geo, marker)))
  min_dist = as.vector(min(sf::st_distance(pts_geo, marker)))

  vdir = paste0(path_to_save, d$site_id, '/', d$var_name, '/')

  print(paste('creating directory in', vdir))
  dir.create(vdir, recursive = T)

  fdir_csv = paste0(vdir, d$site_id, '_', d$var_name, '_', 'm', '.csv')

  # create a dataframe to be saved
  e <- tibble::tibble(
    SiteCode = d$site_id,
    AvgDistance = avg_dist,
    MinDistance = min_dist)

  readr::write_csv(e, fdir_csv)

}
