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
	  
		find = function() {
		  table      <- dplyr::tbl(private$dataSource$getConnection(), "ship_types")
		  ship_types <- table %>%
		    dplyr::collect()
		  return(ship_types)
		}
	)
)