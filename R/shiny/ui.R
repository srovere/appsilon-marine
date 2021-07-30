#
# User interface for Shiny App
#

require(leaflet)
require(shiny)
require(shiny.semantic)

# Define UI for application
shinyUI(
    shiny.semantic::semanticPage(
        title = "Appsilon Test",
        
        # User inputs
        dropDownUI("ship_type_id"),
        dropDownUI("ship_id"),
        
        # Map
        leaflet::leafletOutput(outputId = "coursesMap")
    )
)