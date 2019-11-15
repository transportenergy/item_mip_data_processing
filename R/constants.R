# Some useful conversions, assumptions, and constants
COMMENT_CHAR <- "#"
YEAR_PATTERN <- "^(1|2)[0-9]{3}$"   # a 1 or 2 followed by three digits, and nothing else
ITEM_YEARS <- c(seq(2010, 2040, 5), seq( 2050, 2100, 10))
BASEYEAR <- 2010 # base year assumed for country-level datasets with a single base year
SIGNIFICANT_FIGURES <- 5 # number of significant figures to print output (default is writing all vars to 15 decimal places)

# iTEM columns
ITEM_ID_COLUMNS <- c("Model", "Scenario", "Region", "Variable", "Unit", "Service", "Mode", "Vehicle_type",
                     "Technology", "Fuel", "Liquid_fuel_type", "year")
ITEM_DATA_COLUMNS <- c(ITEM_ID_COLUMNS, "value") # ID columns plus the value column
ITEM_IDVARS_WITH_ALLS <- c("Region", "Service", "Mode", "Vehicle_type", "Technology", "Fuel", "Liquid_fuel_type") # ID columns that collapse to "All" for reporting.

# Downscaling-related columns - same as above but the region column is re-named to iso
DS_ID_COLUMNS <- sub( "Region", "iso", ITEM_ID_COLUMNS)
DS_DATA_COLUMNS <- sub( "Region", "iso", ITEM_DATA_COLUMNS)
DS_IDVARS_WITH_ALLS <- sub( "Region", "iso", ITEM_IDVARS_WITH_ALLS)

DS_OUTPUT_DIR <- "outputs/downscale"
DS_DEFAULT_SCENARIO <- "SSP2" # default socioeconomic realization for downscaling from model regions to countries, for models that provided no socioeconomic data
