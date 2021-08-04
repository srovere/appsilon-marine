#
# User interface for Shiny App
#

require(leaflet)
require(shiny)
require(shinybusy)
require(shiny.semantic)

# Define UI for application
shinyUI(
    shiny.semantic::semanticPage(
        theme = "superhero", title = "Appsilon Test",
        
        # Load CSS
        tags$link(rel = "stylesheet", type = "text/css", href = "css/styles.css?v=2"),
        
        # Use busy spinner
        add_busy_spinner(spin = "fading-circle", color = "#214a4f"),
        
        # Show header
        header(title = "Shiny application proof of concept", description = ""),
        
        # User input        
        cards(
            class = "two",
            card(dropDownUI("ship_type_id", "Vessel type")),
            card(dropDownUI("ship_id", "Vessel"))
        ),
        
        # Separator
        br(),
            
        # Main content,
        leaflet::leafletOutput(outputId = "map", height = "70%")
    )
)