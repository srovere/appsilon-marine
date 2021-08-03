# Load required packages
require(dplyr)
require(purrr)
require(shiny)
require(testthat)

# Load source code for instantiating facades
source(file = "../R/DataSource.R", echo = FALSE)
source(file = "../R/CSVDataSource.R", echo = FALSE)
source(file = "../R/Facade.R", echo = FALSE)
source(file = "../R/ShipFacade.R", echo = FALSE)
source(file = "../R/ShipTypeFacade.R", echo = FALSE)
source(file = "../R/LocationFacade.R", echo = FALSE)

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
        ship_types = '../data/ship_types.csv',
        ships = '../data/ships.csv',
        locations = '../data/locations.csv'
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
# This test performs a selection of one ship type and then one ship.
# Then the longest stretch is verified for that ship. This could be done for
# all the ships, but it will take a lot of time. So I provide this short test
# in order to exemplify.
testServer(expr = {
  # Find ship types
  ship_types_reactive <- findShipTypes()
  ship_types <- shipTypeFacade$find()
  expect_setequal(ship_types_reactive, dplyr::pull(ship_types, ship_type_id))
  
  # Select "High Special"
  high_special_id <- ship_types %>%
    dplyr::filter(name == "High Special") %>%
    dplyr::pull(ship_type_id)
  session$setInputs(ship_type_id = high_special_id)
  ships_reactive <- findShips()
  ships <- shipFacade$find(ship_type_id = high_special_id)
  expect_setequal(ships_reactive, dplyr::pull(ships, ship_id))
  
  # Select "RIVO"
  ship_id <- ships %>%
    dplyr::filter(name == "RIVO") %>%
    dplyr::pull(ship_id)
  session$setInputs(ship_id = ship_id)
  longest_stretch_reactive <- findLongestStretch()
  longest_stretch <- locationFacade$findLongestStretch(ship_id = ship_id)
  expect_setequal(longest_stretch_reactive$location_id, longest_stretch$location_id)
})