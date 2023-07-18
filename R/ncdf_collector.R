#' NCDF collector
#'
#' @param ncdf_path - path to ncdf file
#' @param path_to_save - save directory
#' @param year - year to process the data for
#' @param year_var - year with wave 1 start date
#' @param ... - any other params
#'
#' @return Writes files to disk. No return value.
#' @export
#'
#' @examples
#' ncdf_path = system.file("extdata", "world_soil_moisture_jan2016.nc",
#'  package="endow")
#'f = ncdf_collector(ncdf_path, '/my_folder/', year=2016,
#'  year_var=as.POSIXct('2020-01-01 14:45:18',
#'  format="%Y-%m-%d %H:%M:%S",tz="UTC"),
#'  site_id='KU', lon=-1.62, lat=6.7, dist=30000, var_name='soil_moisture')
ncdf_collector <- function(ncdf_path, path_to_save, year=NULL, year_var=NULL,
                           ...){

  if (!missing(year_var)) {
    y = lubridate::year(year_var)

    if (is.na(y)) {
      print('No year specified in Wave 1 Start variable. Consider adding.')
    }
    else if (y!=year) {
      print('supplied year and Wave 1 Start year are not equal!')
    }

  }

  r = stars::read_stars(ncdf_path)
  r = sf::st_set_crs(r, 'EPSG:4326')

  d = list(...)

  # generate a point for a site
  pt = make_point(d$site_id, d$lon, d$lat)

  # create a buffer within specified distance
  coords_buffer = make_buffer(pt, dist=d$dist)

  # crop
  bofr = r[coords_buffer]

  bo_di = expand_radius(r, bofr, 'sm', d$dist, na_ratio=.5,
                        step_size=5000, pt)

  #bofr = bo_di$buff_ncdf
  new_bofr = bo_di$buff_ncdf

  d$dist = bo_di$dist

  # aggregate from monthly to yearly
  agg_bofr = stars:::aggregate.stars(new_bofr, by = "1 year", FUN = mean, na.rm=T)

  # check if cropped raster is empty
  if (sum(is.na(agg_bofr$sm))/length(agg_bofr$sm)==1) {
    print('Raster is empty')

    # save empty csv
    tbl = tibble::as_tibble_row(list(year = year, var_name = var_name))

    readr::write_csv(tbl, fdir_csv, col_names = F)

  } else {

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

    # subset data by year
    bofr_year = agg_bofr %>%
      dplyr::filter(lubridate::year(time)==year) %>%
      dplyr::select(sm) %>%
      abind::adrop()

    stars::write_stars(bofr_year, fdir, drive='GTiff')

    # prep yearly data as table
    e = mean(bofr_year$sm, na.rm=T)

    tbl = tibble::as_tibble_row(list(year = year, var_name = e))

    if (missing(year)) {
      fdir_csv = paste0(vdir, d$site_id, '_', d$var_name, '_', d$dist, 'm', '.csv')
    } else {
      fdir_csv = paste0(vdir, d$site_id, '_', d$var_name, '_', d$dist, 'm', '_', year, '.csv')
    }

    # save csv
    readr::write_csv(tbl, fdir_csv, col_names = F)

  }

}
