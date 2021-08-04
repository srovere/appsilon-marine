require(R6)
require(dplyr)
require(dbplyr)
require(magrittr)

ShipTypeFacade <- R6Class("ShipTypeFacade",
	inherit = Facade,
	public = list(
	  initialize = function(dataSource) {
	    private$dataSource <- dataSource
	  },
	  
		find = function(ship_type_id = NULL) {
		  filters    <- list(ship_type_id = ship_type_id)
		  table      <- dplyr::tbl(private$dataSource$getConnection(), "ship_types")
		  ship_types <- private$find(table, filters) %>%
		    dplyr::collect()
		  return(ship_types)
		}
	)
)