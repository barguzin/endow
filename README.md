
<!-- README.md is generated from README.Rmd. Please edit that file -->

# endow

<!-- badges: start -->
<!-- badges: end -->

The package simplifies data collection and data processing pipelines for
the ENDOW project. The code can be re-used to collect a series of
gespatial variables for a given point on Earth.

## Installation

You can install the development version of endow from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("barguzin/endow")
```

## Example

Endow package provides a series of utility functions to simplify data
collection:

``` r
library(endow)
## basic example code

my_point = make_point("site A", lon=45, lat=45)
```
