#' build_ipcc_template: convert the iTEM MIP3 database into the format for the IPCC AR6 inter-comparison
#'
#' @param item_data data table with iTEM template data
#' @param ipcc_mapping table with variable assignments from iTEM to IPCC AR6 template
#' @details This function performs a post-hoc translation from the iTEM MIP3 output to
#' the IPCC AR6 template
#' @importFrom assertthat assert_that
#' @importFrom dplyr left_join
#' @importFrom readr read_csv
#' @importFrom tidyr complete gather nesting spread
#' @export
build_ipcc_template <- function(item_data_fn,
                                item_data = NA,
                                ipcc_mapping_fn = "ipcc/item_to_ipcc_mapping.csv",
                                output_folder){

  assert_that(is.character(item_data_fn))
  assert_that(is.character(ipcc_mapping_fn))

  if(!is.na(item_data)){
    assert_that(is.tibble(item_data))
  } else {
    item_data <- read_csv(item_data_fn)
  }

  ipcc_mapping <- load_data_file(ipcc_mapping_fn, quiet = TRUE)
  year_columns <- names(item_data[grepl(YEAR_PATTERN, names(item_data))])

  ipcc_data <- inner_join(item_data, ipcc_mapping,
                          by = intersect(names(item_data), names(ipcc_mapping)))
  ipcc_data[year_columns] <- ipcc_data[year_columns] * ipcc_data$Unit_conv
  ipcc_data <- ipcc_data %>%
    select(Model, Scenario, Region, Category = IPCC_Category, Variable = IPCC_Variable, Unit = IPCC_Unit,
           matches(YEAR_PATTERN))

  save_output(ipcc_data, output_folder)
  return(ipcc_data)
}
