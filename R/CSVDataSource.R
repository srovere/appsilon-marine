require(R6)
require(data.table)
require(RSQLite)
require(dplyr)
require(dbplyr)
require(tibble)

CSVDataSource <- R6Class("CSVDataSource",
  inherit = DataSource,
	public = list(
	  initialize = function(parameters) {
	    if (is.null(parameters$tables) || (length(parameters$tables) == 0)) {
	      stop("You must define at leat ine table")
	    }
	    
	    # Create connection
	    private$connection <- DBI::dbConnect(RSQLite::SQLite(), ":memory:")
	    
	    # Bind tables to connection
	    tables <- parameters$tables
	    for (table in names(tables)) {
	      file <- tables[[table]]
	      data <- data.table::fread(file = file) %>%
	        tibble::as_tibble()
	      dplyr::copy_to(dest = private$connection, df = data, name = table)
	    }
	  }
	)
)
