require(R6)
require(dplyr)
require(dbplyr)

Facade <- R6Class("Facade",
	private = list(
	  # Data source
	  dataSource = NULL,
	  
	  # Basic generic finder
	  find = function(dataset, filters) {
	    for (col.name in names(filters)) {
	      if (! is.null(filters[[col.name]]) && (length(filters[[col.name]]) > 0)) {
	        field.name <- rlang::sym(col.name)
	        if (length(filters[[col.name]]) > 1) {
	          field.values <- filters[[col.name]]
	          dataset      <- dataset %>% dplyr::filter(UQ(field.name) %in% field.values)
	        } else {
	          field.value <- filters[[col.name]]
	          if (! is.na(field.value)) {
	            dataset <- dataset %>% 
	              dplyr::filter(UQ(field.name) == field.value)
	          } else {
	            dataset <- dataset %>% 
	              dplyr::filter(is.na(UQ(field.name)))
	          }
	        }
	      }
	    }
	    return (dataset)
	  }
	)
)
