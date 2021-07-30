require(R6)
require(dplyr)
require(dbplyr)

DataSource <- R6Class("DataSource",
	private = list(
	  connection = NULL
	),
	public = list(
	  initialize = function() {
	    private$connection <<- NULL
	  },
	  getInstance = function(driver = c('CSV', 'MySQL', 'PostgreSQL'), parameters) {
	    driver <- base::match.arg(driver)
	    if (driver == "CSV") {
	      return(CSVDataSource$new(parameters))
	    } else {
	      stop(sprintf("Unsupported driver: %s", driver))
	    }
	  },
	  getConnection = function() {
	    return(private$connection)
	  }
	)
)
