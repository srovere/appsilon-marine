require(R6)
require(dplyr)
require(dbplyr)
require(magrittr)

LocationFacade <- R6Class("LocationFacade",
	inherit = Facade,
	public = list(
	  initialize = function(dataSource) {
	    private$dataSource <- dataSource
	  },
	  
		find = function(ship_id = NULL) {
		  filters   <- list(ship_id = ship_id)
		  table     <- dplyr::tbl(private$dataSource$getConnection(), "locations")
		  locations <- private$find(table, filters) %>%
		    dplyr::arrange(datetime) %>%
		    dplyr::collect()
		  return(locations)
		}
	)
)