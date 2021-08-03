library(shiny)
library(testthat)

# Common unit tests
testthat::test_file("tests/testthat/test_data.r")
testthat::test_file("tests/testthat/test_finders.r")

# Shiny unit tests
shiny::runTests()
