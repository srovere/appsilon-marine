# 1. Overview

The purpose of this document is to explain the processes that took place during the development of this *proof of concept*. The initial task carried out was the normalization of data (which also included the calculation of distances between consecutive observations). In order to access the resulting information in a transparent manner, a scalable structure of classes was implemented. Then, a Shiny application was developed, following the guidelines provided by Appsilon. Finally, unit tests were created to ensure a correct operation.

This application is currently deployed at https://srovere.shinyapps.io/appsilon-marine/.

# 2. Data normalization and optimization

The provided dataset was a CSV file with the following attributes:

* LAT - ship’s latitude
* LON - ship’s longitude
* SPEED - ship’s speed in knots
* COURSE - ship’s course as angle
* HEADING - ship’s compass direction
* DESTINATION - ship’s destination (reported by the crew)
* FLAG - ship’s flag
* LENGTH - ship’s length in meters
* SHIPNAME - ship’s name
* SHIPTYPE - ship’s type
* SHIP_ID - ship’s unique identifier
* WIDTH - ship’s width in meters
* DWT - ship’s deadweight in tones
* DATETIME - date and time of the observation
* PORT - current port reported by the vessel
* Date - date extracted from DATETIME
* Week_nb - week number extracted from date
* Ship_type - ship’s type from SHIPTYPE
* Port - current port assigned based on the ship’s location
* Is_parked - indicator whether the ship is moving or not 

This dataset is not normalized as it includes redundant and duplicated information. For example, Date and Week_nb can be derived from DATETIME. For this reason, a normalization process was carried out, resulting in the following 3 entities:

* **ship_types** = (*ship_type_id*, name)

* **ships** = (*ship_id*, ship_type_id, name, flag, length, width, dead_weight)

* **location** = (*location_id*, ship_id, datetime, latitude, longitude, speed, course, heading, destination, parked, observation, distance)

During this normalization process, the distance between two given observations was calculated. So, if O1 and O2 are two consecutive observations for any given ship, <em>O2.distance</em> represents the distance travelled by that ship between O1 and O2. Although distance can be derived from latitude/longitude and computed on the fly, it is better to have this information pre-calculated to improve the overall performance of the Shiny application.

The resulting files are stored in <em>data</em> directory. These files are not versioned (because the are too large), but they can be downloaded from https://1drv.ms/u/s!As8wkljo8CRlgpBdoR-2ryFVaXIODg?e=l1EI26.

# 3. Data accesing

After having normalized the original dataset, the resulting entities where stored in CSV files (just for the sake of simplicity and considering that this application is a proof of concept). However, data access was designed considering scalability as a fundamental need. For this reason, the following classes were implemented:


| Class | Description |
| ------|:-----------:|
| DataSource | Singleton abstract class that represents a data source (CSV, MySQL, PostgreSQL, etc). |
| CSVDataSource | At the moment, the only data source available. This data source is capable of holding in-memory tables read from CSV files. |
| Facade | This abstract class holds an instance of a data source and provides access to a given entity. It also implements a generic finder method that can be used by descendant classes. |
| ShipTypeFacade | This facade provides access to *ship_types* entity. |
| ShipFacade | This facade provides access to *ships* entity. |
| LocationFacade | This facade provides access to *location* entity. |

# 4. UI and Server development

This Shiny application was developed using [shiny.semantics] (https://github.com/Appsilon/shiny.semantic) package. The application is divided in three files (global.R, ui.R and server.R). The user interface has three componets: 2 dropdowns to allow the selecction of a *vessel type* and a *vessel* (considering the type selected beforehand). When a vessel (ship) is selected, the map at the bottom of the page is redrawn. The longest stretch sailed by the selected ship is shown along with other useful information. A few styles were modified using the CSS file located at *www/css/styles.css*.

# 5. Testing

To ensure the application correct operation, a few unit tests were implemented. These tests can be found in *tests* directory and may be run using *run_tests.r* script located in the root directory. The units tests implemented include:

* *tests/testthat/test_data.r*: Tests for checking attributes' names and types.
* *tests/testthat/test_finders.r*: Tests for checking data finders *using facades.
* *tests/test_shiny.r*: Reactivity tests using Shiny application.
