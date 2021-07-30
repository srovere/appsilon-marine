#
# Server logic for Shiny App
#

require(shiny)
require(shiny.semantic)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
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
                dplyr::arrange(name)

            choices        <- dplyr::pull(ships, ship_id)
            names(choices) <- dplyr::pull(ships, name)
            return(choices)
        }
    })
    findLocations <- shiny::reactive({
        if (! is.null(input$ship_id) && (input$ship_id != "")) {
            return(locationFacade$find(ship_id = input$ship_id))
        }
        return(NULL)
    })
    
    # User input logic (ship types and ships)
    dropDownServer("ship_type_id", "Vessel type", findShipTypes)
    dropDownServer("ship_id", "Vessel", findShips)
    
    # Map for rendering courses
    output$coursesMap <- leaflet::renderLeaflet({
        leaflet::leaflet() %>%
            leaflet::addTiles(map = ., urlTemplate = config$basemap$url, 
                              attribution = config$basemap$attribution)
    })
    observe({
        locations <- findLocations()
        warning(paste0("Locations: ", nrow(locations)))
        if (! is.null(locations) && (nrow(locations) > 1)) {
            # Find longest distance between 2 observations
            longest_distance <- locations %>%
                dplyr::arrange(dplyr::desc(distance), dplyr::desc(datetime)) %>%
                dplyr::top_n(1)
            
            # Create line that represents the trip between observations
            trip <- sf::st_linestring(
                matrix(c(longest_distance$previous_longitude, longest_distance$previous_latitude,
                         longest_distance$longitude, longest_distance$latitude), nrow = 2, ncol = 2, byrow = TRUE)
            )
            trip.extent   <- sf::st_bbox(trip)
            trip.centroid <- sf::st_centroid(trip)
            
            # Render map
            leaflet::leafletProxy("coursesMap") %>%
                leaflet::addPolygons(map = ., data = trip) %>%
                leaflet::fitBounds(map = ., lng1 = as.double(trip.extent["xmin"]), 
                                   lng2 = as.double(trip.extent["xmax"]),
                                   lat1 = as.double(trip.extent["ymin"]), 
                                   lat2 = as.double(trip.extent["ymax"]))
                
        }
    })
})