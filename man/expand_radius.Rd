% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils.R
\name{expand_radius}
\alias{expand_radius}
\title{Expand radius}
\usage{
expand_radius(
  stars_obj,
  cropped_stars,
  attr_name,
  dist,
  na_ratio = 0.25,
  step_size = 5000,
  pnt
)
}
\arguments{
\item{stars_obj}{description}

\item{cropped_stars}{cropped stars object (sf)}

\item{attr_name}{attribute name for which sparsity is considered (char)}

\item{dist}{distance in meters}

\item{na_ratio}{ratio of NA values (0, 1)}

\item{step_size}{step size in meters}

\item{pnt}{an sf object with point geometry (build from site coords)}
}
\value{
list w 2 elements: cropped raster/ncdf and dist
}
\description{
For data with patchy / sparse coverage iteratively increase buffer
distance, until the ratio of non-null values hits the threshhold
}
\examples{

lng = -1.62
lat = 6.7
dist = 5000
ss_id = 'KI'

pnt = make_point(lon = lng, lat = lat, site_id=ss_id)
buff = make_buffer(pnt, dist)

ncdf_path = system.file("extdata", "world_soil_moisture_jan2016.nc",
 package="endow")

s = stars::read_stars(ncdf_path)

s = sf::st_set_crs(s, 'EPSG:4326')

b = s[buff]

c = expand_radius(s, b, attr_name='sm', dist=dist, na_ratio=.5,
 step_size=5000, pnt=pnt)

}
