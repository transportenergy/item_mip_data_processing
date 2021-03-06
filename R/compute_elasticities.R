#' Compute elasticities from downscaled iTEM dataset
#'
#' @param data data table with the variables necessary to perform the computations
#' @param number_variable number of the logarithm
#' @param base_variable base used in the logarithm
#' @param year_range timespan to use in computing elasticities.
#' @param models which models to use (default = All)
#' @param regions which regions to use (default = Global)
#' @details This function computes and produces boxplots of the elasticities between specified variables of interest
#' @importFrom assertthat assert_that
#' @importFrom dplyr mutate if_else group_by summarise ungroup filter select
#' @importFrom tidyr gather drop_na
#' @importFrom magrittr "%>%"
#' @importFrom ggplot2 aes ggplot geom_boxplot theme element_text
#' @export
compute_elasticities <- function( item_data,
                                  number_variable = "Passenger Activity per capita",
                                  base_variable = "GDP per capita",
                                  year_range = c(2010, 2050),
                                  models = "All",
                                  regions = "Global",
                                  return_boxplot = TRUE, ...){

  if(models == "All") models <- unique(item_data$Model)
  number_data <- subset(item_data,
                        Variable == number_variable &
                          Model %in% models &
                          Region %in% regions &
                          Technology == "All" &
                          Fuel == "All") %>%
    select(-Variable, -Unit, -Technology, -Fuel, -Liquid_fuel_type)
  base_data <- subset(item_data,
                      Variable == base_variable &
                        Model %in% models &
                        Region %in% regions) %>%
    select(-Variable, -Unit, -Service, -Mode, -Vehicle_type, -Technology, -Fuel, -Liquid_fuel_type)

  # If the data table is spread by year, re-set that in these two subsetted tables
  if(any(grepl(YEAR_PATTERN, names(item_data)))){
    number_data <- gather(number_data, key = year, value = "number", matches(YEAR_PATTERN)) %>%
      mutate(year = as.integer(year)) %>%
      drop_na(number) %>%
      dplyr::filter(number > 0)
    base_data <- gather(base_data, key = year, value = "base", matches(YEAR_PATTERN)) %>%
      mutate(year = as.integer(year)) %>%
      drop_na(base) %>%
      dplyr::filter(base > 0)
  }

  # Join the number and base tables
  elas_data <- left_join(number_data, base_data, by = c("Model", "Scenario", "Region", "year")) %>%
    group_by(Model, Scenario, Region, Service, Mode, Vehicle_type) %>%
    # The lower year is the one indicated, if available; otherwise defaults to the minimum reported year
    # for the model/scenario. The upper year is determined using the same logic.
    mutate(lower_year = if_else(year_range[1] %in% year, year_range[1], min(year))) %>%
    mutate(upper_year = if_else(year_range[2] %in% year, year_range[2], max(year))) %>%
    mutate(number_ratio = number / number[year == lower_year],
           base_ratio = base / base[year == lower_year]) %>%
    ungroup() %>%
    dplyr::filter(year == upper_year) %>%
    mutate(elasticity = log(number_ratio, base = base_ratio),
           Cat_mode = paste(Service, Mode, Vehicle_type)) %>%
    select(Model, Scenario, Region, Service, Mode, Vehicle_type, Cat_mode, elasticity)

  if(return_boxplot){
    elas_plot <- ggplot(elas_data) + geom_boxplot(aes(x = Cat_mode, y = elasticity)) +
      theme(axis.text.x = element_text(angle = 90, hjust = 1))
    return(elas_plot)
  } else {
    return(elas_data)
  }
}

