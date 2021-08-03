testthat::context("Data integrity tests")

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
test_that("Ship type data (names and types)", {
  # Find ship types
  ship_types <- shipTypeFacade$find()
  
  # Attributes (names and types)
  attributes <- list(
    ship_type_id = 'integer',
    name = 'character'
  )

  # Check attribute names
  testthat::expect_setequal(object = colnames(ship_types),
                            expected = names(attributes))
  
  # Check attribute types
  testthat::expect_equal(object = unlist(purrr::map(colnames(ship_types), 
                                                    ~class(ship_types[[.x]]))),
                            expected = unlist(unname(attributes)))
})

test_that("Ship data (names and types)", {
  # Find ships
  ships <- shipFacade$find()
  
  # Attributes (names and types)
  attributes <- list(
    ship_id = 'integer64',
    ship_type_id = 'integer',
    name = 'character',
    flag = 'character',
    length = 'integer',
    width = 'integer',
    dead_weight = 'integer'
  )
  
  # Check attribute names
  testthat::expect_setequal(object = colnames(ships),
                            expected = names(attributes))
  
  # Check attribute types
  testthat::expect_equal(object = unlist(purrr::map(colnames(ships), 
                                                    ~class(ships[[.x]]))),
                         expected = unlist(unname(attributes)))
})

test_that("Location data (names and types)", {
  # Find locations
  locations <- locationFacade$find()
  
  # Attributes (names and types)
  attributes <- list(
    location_id = 'integer',
    ship_id = 'integer64',
    datetime = 'numeric',
    longitude = 'numeric',
    latitude = 'numeric',
    speed = 'integer',
    course = 'integer',
    heading = 'integer',
    destination = 'character',
    parked = 'integer',
    previous_longitude = 'numeric',
    previous_latitude = 'numeric',
    observation = 'integer',
    distance = 'numeric'
  )
  
  # Check attribute names
  testthat::expect_setequal(object = colnames(locations),
                            expected = names(attributes))
  
  # Check attribute types
  testthat::expect_equal(object = unlist(purrr::map(colnames(locations), 
                                                    ~class(locations[[.x]]))),
                         expected = unlist(unname(attributes)))
})