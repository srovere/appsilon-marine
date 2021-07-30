#
# Global initialization code. This code is intended to read a configuration 
# file (YAML) and to create a facade instance for accessing the data (at the
# moment data is stored in a CSV file)
#

# Load packages
require(yaml)

# Read configuration file
config <- yaml::yaml.load_file("configuration.yml")

# Load classes for data handling
source(file = "../DataSource.R", echo = FALSE)
source(file = "../CSVDataSource.R", echo = FALSE)
source(file = "../Facade.R", echo = FALSE)
source(file = "../ShipFacade.R", echo = FALSE)
source(file = "../ShipTypeFacade.R", echo = FALSE)
source(file = "../LocationFacade.R", echo = FALSE)

# Create instance for data source
dataSource <- DataSource$new()$getInstance(driver = config$data_source$driver, 
                                           parameters = config$data_source$parameters)

# Create facades
shipTypeFacade <- ShipTypeFacade$new(dataSource)
shipFacade <- ShipFacade$new(dataSource)
locationFacade <- LocationFacade$new(dataSource)

# Load modules
source(file = "modules/inputs.R", echo = FALSE)