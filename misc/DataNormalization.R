# Clean environment
rm(list = objects())

# Load packages
require(data.table)
require(dplyr)
require(purrr)
require(sf)

# File description:
#
# LAT - ship’s latitude (location)
# LON - ship’s longitude (location)
# SPEED - ship’s speed in knots (location)
# COURSE - ship’s course as angle (location)
# HEADING - ship’s compass direction (location)
# DESTINATION - ship’s destination (reported by the crew) (location)
# FLAG - ship’s flag (ship)
# LENGTH - ship’s length in meters (ship)
# SHIPNAME - ship’s name (ship)
# SHIPTYPE - ship’s type (ship/ship_type)
# SHIP_ID - ship’s unique identifier (ship/location)
# WIDTH - ship’s width in meters  (ship)
# DWT - ship’s deadweight in tones (ship)
# DATETIME - date and time of the observation (location)
# PORT - current port reported by the vessel (location)
# Date - date extracted from DATETIME (location - derived from datetime)
# Week_nb - week number extracted from date (location - derived from datetime)
# Ship_type - ship’s type from SHIPTYPE (ship_type)
# Port - current port assigned based on the ship’s location (location)
# Is_parked - indicator whether the ship is moving or not (location)
#

# Read HUGE file using data.table (fastest method)
data <- data.table::fread(file = "data/all.csv", sep = ",")

# Identify ship types
ship_types <- data %>%
  dplyr::distinct(SHIPTYPE, ship_type) %>%
  dplyr::rename(ship_type_id = SHIPTYPE, name = ship_type) %>%
  dplyr::arrange(ship_type_id)

# Identify ships. There are duplicated shipnames: different names/types with
# the same ID. In this case, I'll select the last occurrence (using datetime).
ship_unique_ids <- data %>%
  dplyr::group_by(SHIP_ID) %>%
  dplyr::summarize(DATETIME = max(DATETIME))
ships <- data %>%
  dplyr::inner_join(ship_unique_ids, by = c("SHIP_ID", "DATETIME")) %>%
  dplyr::distinct(FLAG, LENGTH, SHIPNAME, SHIPTYPE, SHIP_ID, WIDTH, DWT) %>%
  dplyr::rename(ship_id = SHIP_ID, ship_type_id = SHIPTYPE, name = SHIPNAME,
                flag = FLAG, length = LENGTH, width = WIDTH, dead_weight = DWT) %>%
  dplyr::arrange(ship_id) %>%
  dplyr::select(ship_id, ship_type_id, name, flag, length, width, dead_weight)

# Identify locations
locations <- data %>%
  dplyr::distinct(SHIP_ID, LAT, LON, SPEED, COURSE, HEADING, DESTINATION, DATETIME, port, is_parked) %>%
  dplyr::rename(ship_id = SHIP_ID, datetime = DATETIME, latitude = LAT, longitude = LON, 
                speed = SPEED, course = COURSE, heading = HEADING, destination = DESTINATION,
                parked = is_parked) %>%
  dplyr::mutate(location_id = dplyr::row_number()) %>%
  dplyr::select(location_id, ship_id, datetime, latitude, longitude, speed, course, heading,
                destination, parked) %>%
  dplyr::arrange(ship_id, datetime, parked) %>%
  # Calculate previous locations for each ship. The previous location for each ships
  # is defined as the same location for easy distance calculation. 
  dplyr::group_by(ship_id) %>%
  dplyr::mutate(previous_latitude = dplyr::lag(latitude),
                previous_longitude = dplyr::lag(longitude),
                observation = dplyr::row_number(),
                previous_latitude = dplyr::if_else(observation > 1, previous_latitude, latitude),
                previous_longitude = dplyr::if_else(observation > 1, previous_longitude, longitude)) %>%
  dplyr::ungroup()

# Pre-calculate distance (in meters) for each observation.
# The first observation of each ship has distance = NA
from <- locations %>%
  dplyr::select(location_id, latitude, longitude) %>%
  sf::st_as_sf(x = ., coords = c("longitude", "latitude"), crs = 4326) %>%
  dplyr::arrange(location_id)
to <- locations %>%
  dplyr::select(location_id, previous_latitude, previous_longitude) %>%
  sf::st_as_sf(x = ., coords = c("previous_longitude", "previous_latitude"), crs = 4326) %>%
  dplyr::arrange(location_id)
distances <- dplyr::bind_cols(
  dplyr::select(sf::st_drop_geometry(from), location_id),
  tibble::tibble(distance = as.numeric(sf::st_distance(x = from, y = to, by_element = TRUE)))
)
  
# Store distances. The first observation of each ship has distance = NA
locations <- locations %>%
  dplyr::inner_join(distances, by = c("location_id")) %>%
  dplyr::mutate(distance = dplyr::if_else(observation > 1, distance, as.numeric(NA))) %>%
  dplyr::select(-previous_latitude, -previous_longitude)

# Save output CSV files
readr::write_tsv(x = ship_types, file = "data/ship_types.csv")
readr::write_tsv(x = ships, file = "data/ships.csv")
readr::write_tsv(x = locations, file = "data/locations.csv")
