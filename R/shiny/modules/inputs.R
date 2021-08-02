# Define the UI for dropdowns
dropDownUI <- function(id, label) {
  ns <- NS(id)
  tagList(
    div(class = "content",
        div(class = "header ui-dropdown", label),
        shiny::uiOutput(ns("out"))
    )
  )
}

# Define the server logic for dropdowns
dropDownServer <- function(id, label, reactiveFinder) {
  moduleServer(
    id,
    function(input, output, session) {
      output$out <- shiny::renderUI({
        choices <- reactiveFinder()
        if (! is.null(choices)) {
          shiny.semantic::dropdown_input(
            input_id = id,
            choices = names(choices),
            choices_value = unname(choices)
          )
        }
      })
    }
  )
}