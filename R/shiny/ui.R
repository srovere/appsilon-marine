#
# User interface for Shiny App
#

require(leaflet)
require(shiny)
require(shiny.semantic)

# Define UI for application
shinyUI(
    shiny.semantic::semanticPage(
        theme = "superhero", title = "Appsilon Test",
        
        # Load CSS
        tags$link(rel = "stylesheet", type = "text/css", href = "css/styles.css"),
        
        # Show header
        header(title = "Appsilon Test", description = ""),
        
        # User input        
        cards(
            class = "two",
            card(dropDownUI("ship_type_id", "Vessel type")),
            card(dropDownUI("ship_id", "Vessel"))
        ),
        
        br(),
            
        # Main content,
        leaflet::leafletOutput(outputId = "coursesMap")
    )
)