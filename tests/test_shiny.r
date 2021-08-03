testthat::context("Shiny app test")

# Load required packages
require(dplyr)
require(purrr)
require(shiny)
require(testthat)



# Tests
testServer(server, expr = {
  warning(output$ship_type_id)
  #expect_equal(output$ship_type_id, "1 2 3 4 5 6")
  
})