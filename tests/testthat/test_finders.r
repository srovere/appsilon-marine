testthat::context("Data finding tests")

# Load required packages
require(dplyr)
require(purrr)
require(readr)
require(testthat)

# Load source code for instantiating facades
source(file = "../../R/DataSource.R", echo = FALSE)
source(file = "../../R/CSVDataSource.R", echo = FALSE)
source(file = "../../R/Facade.R", echo = FALSE)
source(file = "../../R/ShipFacade.R", echo = FALSE)
source(file = "../../R/ShipTypeFacade.R", echo = FALSE)
source(file = "../../R/LocationFacade.R", echo = FALSE)

# Facades for accesing data
shipTypeFacade <<- NULL
shipFacade     <<- NULL
locationFacade <<- NULL

# Initial setup
testthat::setup({
  # Define data source
  dataSource     <- DataSource$new()$getInstance(
    driver = "CSV",
    parameters = list(
      tables = list(
        ship_types = '../../data/ship_types.csv',
        ships = '../../data/ships.csv',
        locations = '../../data/locations.csv'
      )
    )
  )

  # Instantiate facade
  shipTypeFacade <<- ShipTypeFacade$new(dataSource)
  shipFacade     <<- ShipFacade$new(dataSource)
  locationFacade <<- LocationFacade$new(dataSource)
})

# Tear down
testthat::teardown({
  shipTypeFacade <<- NULL
  shipFacade     <<- NULL
  locationFacade <<- NULL
})

# Tests
test_that("Find ships by type", {
  # Find ship types
  ship_types <- shipTypeFacade$find()
  
  # Find ships for each type
  purrr::walk(
    .x = dplyr::pull(ship_types, ship_type_id),
    .f = function(ship_type_id) {
      ships <- shipFacade$find(ship_type_id = ship_type_id)
      
      # Check that returned ships are of the expected type
      testthat::expect_true(all(ships$ship_type_id == ship_type_id))    
    }
  )
})

test_that("Find locations by ship", {
  # Find ship types
  ships <- shipFacade$find()

  # Find locations for each ship
  purrr::walk(
    .x = dplyr::pull(ships, ship_id),
    .f = function(ship_id) {
      locations <- locationFacade$find(ship_id = ship_id)

      # Check that returned locations have the expected ship
      testthat::expect_true(all(locations$ship_id == ship_id))
    }
  )
})
