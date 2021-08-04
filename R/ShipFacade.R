require(R6)
require(dplyr)
require(dbplyr)
require(magrittr)

ShipFacade <- R6Class("ShipFacade",
	inherit = Facade,
	public = list(
	  initialize = function(dataSource) {
	    private$dataSource <- dataSource
	  },
	  
		find = function(ship_type_id = NULL, ship_id = NULL, flag = NULL) {
		  filters <- list(ship_type_id = ship_type_id, ship_id = ship_id, flag = flag)
		  table   <- dplyr::tbl(private$dataSource$getConnection(), "ships")
		  ships   <- private$find(table, filters) %>%
		    dplyr::collect()
		  return(ships)
		}
	)
)