test_that("simple feature geometry is okay", {
  expect_equal(sf::st_geometry_type(sf::st_point(c(0,0))),
               sf::st_geometry_type(make_point('AA', 0,0)))
})
