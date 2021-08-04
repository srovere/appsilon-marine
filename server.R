#
# Server logic for Shiny App
#

require(htmltools)
require(shiny)
require(shinybusy)
require(shiny.semantic)
require(sf)

# Define server logic required to draw a histogram
shinyServer(function(input, output, session) {
    # Reactives for findind entities (ship types, ships & locations)
    findShipTypes <- shiny::reactive({
        shipTypes <- shipTypeFacade$find() %>%
            dplyr::arrange(name)
        
        choices        <- dplyr::pull(shipTypes, ship_type_id)
        names(choices) <- dplyr::pull(shipTypes, name)
        return(choices)
    })
    findShips <- shiny::reactive({
        if (! is.null(input$ship_type_id) && (input$ship_type_id != "")) {
            ships <- shipFacade$find(ship_type_id = input$ship_type_id) %>%
                dplyr::mutate(full_name = sprintf("%s (%s)", name, flag)) %>%
                dplyr::arrange(full_name)

            choices        <- dplyr::pull(ships, ship_id)
            names(choices) <- dplyr::pull(ships, full_name)
            return(choices)
        }
    })
    findLongestStretch <- shiny::reactive({
        if (! is.null(input$ship_id) && (input$ship_id != "")) {
            return(locationFacade$findLongestStretch(ship_id = input$ship_id))
        }
        return(NULL)
    })
    
    # User input logic (ship types and ships)
    dropDownServer("ship_type_id", "Vessel type", findShipTypes)
    dropDownServer("ship_id", "Vessel", findShips)
    
    # Map for rendering courses
    output$map <- leaflet::renderLeaflet({
        leaflet::leaflet(options = leafletOptions(zoomControl = FALSE)) %>%
            leaflet::addTiles(map = ., urlTemplate = config$basemap$url, 
                              attribution = config$basemap$attribution) %>%
            leaflet::setView(map = ., zoom = config$basemap$zoom,
                             lng = config$basemap$center$longitude,
                             lat = config$basemap$center$latitude)
    })
    observe({
        # Find longest stretch
        longest_stretch <- findLongestStretch()   
        if (! is.null(longest_stretch) && (nrow(longest_stretch) == 1)) {
            # Get previous location
            previous_location <- locationFacade$findPreviousLocation(longest_stretch)
            
            # Create a line that represents the trip between observations
            trip <- sf::st_linestring(
                matrix(c(previous_location$longitude, previous_location$latitude,
                         longest_stretch$longitude, longest_stretch$latitude), nrow = 2, ncol = 2, byrow = TRUE)
            )
            trip.extent   <- sf::st_bbox(trip)
            trip.centroid <- sf::st_centroid(trip)
            
            # Create point markers for source and destination
            timestamps <- as.POSIXct(c(previous_location$datetime, longest_stretch$datetime), origin="1970-01-01", tz="UTC")
            markers <- tibble::tibble(
                is_destination = c(FALSE, TRUE),
                longitud = c(previous_location$longitude, longest_stretch$longitude),
                latitud = c(previous_location$latitude, longest_stretch$latitude),
                datetime = timestamps
            ) %>%
                dplyr::mutate(label = sprintf("<b>%s</b><br>%s UTC", dplyr::if_else(is_destination, "Arrival", "Departure"),
                                              format(datetime, "%Y-%m-%d %H:%m:%S"))) %>%
                sf::st_as_sf(x = ., coords = c("longitud", "latitud"))
            
            # Calculate time traveled
            time_traveled <- difftime(timestamps[2], timestamps[1], units = "secs")
            
            # Define text for legend
            legend <- htmltools::HTML(
                sprintf("Heading towards <b>%s</b><br/>Course: %dº | Speed: %d kts<br/>Distance travelled: %.2f m<br>Time travelled: %s",
                        longest_stretch$destination, longest_stretch$course, longest_stretch$speed, longest_stretch$distance, 
                        lubridate::seconds_to_period(time_traveled))
            )
            
            # Render map
            leaflet::leafletProxy("map", data = trip) %>%
                # Clear all polygons/pop-ups
                leaflet::clearPopups(map = .) %>%
                leaflet::clearShapes(map = .) %>%
                leaflet::clearMarkers(map = .) %>%
                leaflet::clearControls(map = .) %>%
                # Draw path
                leaflet::addPolygons(map = .) %>%
                # Add legend for showing stretch information
                leaflet::addControl(map = ., position = 'topright', html = legend) %>%
                # Add source/destination markers
                leaflet::addCircleMarkers(map = ., data = markers,
                                          label = ~purrr::map(.x = label, .f = htmltools::HTML),
                                          labelOptions = labelOptions(noHide = T)) %>%
                # Fit bounds
                leaflet::fitBounds(map = ., lng1 = as.double(trip.extent["xmin"]), 
                                   lng2 = as.double(trip.extent["xmax"]),
                                   lat1 = as.double(trip.extent["ymin"]), 
                                   lat2 = as.double(trip.extent["ymax"]))
        } else {
            # Clear map
            leaflet::leafletProxy("map") %>%
                leaflet::clearPopups(map = .) %>%
                leaflet::clearShapes(map = .) %>%
                leaflet::clearMarkers(map = .) %>%
                leaflet::clearControls(map = .)
        }
    })
})