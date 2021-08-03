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
		},
		
		findPreviousLocation = function(location) {
		  previous_location <- self$find(ship_id = location$ship_id) %>%
		    dplyr::filter(ship_id == location$ship_id & observation == location$observation - 1)
		  return(previous_location)
		},
		
		findLongestStretch = function(ship_id) {
		  longest_stretch <- self$find(ship_id = ship_id) %>%
		    dplyr::arrange(dplyr::desc(distance), dplyr::desc(datetime)) %>%
		    dplyr::slice_max(1)
		  return(longest_stretch)
		}
	)
)