#
# Global initialization code. This code is intended to read a configuration 
# file (YAML) and to create a facade instance for accessing the data (at the
# moment data is stored in a CSV file)
#

# Load packages
require(yaml)

# Read configuration file
config <- yaml::yaml.load_file("configuration.yml")

# Create instance for data source
dataSource <- DataSource$new()$getInstance(driver = config$data_source$driver, 
                                           parameters = config$data_source$parameters)

# Create facades
shipTypeFacade <- ShipTypeFacade$new(dataSource)
shipFacade <- ShipFacade$new(dataSource)
locationFacade <- LocationFacade$new(dataSource)