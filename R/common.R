#' find_data_file
#'
#' Find an internal, i.e. included with the package, data file.
#' @param filename Filename (extension optional) to find
#' @param optional Logical: file optional to find?
#' @param quiet Logical - suppress messages?
#' @return Fully qualified file name, or NULL if file not found but is optional.
#' @details Throws an error if file not found (and file is not optional).
#' @importFrom assertthat assert_that
find_data_file <- function(filename, optional = FALSE, quiet = FALSE) {
  assert_that(is.character(filename))
  assert_that(length(filename) == 1)
  assert_that(is.logical(optional))
  assert_that(is.logical(quiet))

  extensions <- c("", ".csv", ".yaml")
  for(ex in extensions) {
    fqfn <- system.file("extdata/model", paste0(filename, ex), package = "item")
    if(fqfn != "") {
      if(!quiet) cat("Found", fqfn, "...\n")
      return(fqfn)  # found it
    }
  }
  if(optional) {
    return(NULL)
  } else {
    stop("Couldn't find required data ", filename)
  }
}

#' load_data_file
#'
#' Load an internal, i.e. included with the package, data file.
#' @param filename filename of file to load
#' @param optional Logical indicating whether file is optional
#' @param quiet Logical - suppress messages?
#' @details Optional files that are not found are returned as NA.
#' @return A data frame (csv) or yaml list.
#' @importFrom magrittr "%>%"
#' @importFrom assertthat assert_that
#' @importFrom yaml yaml.load_file
#' @importFrom data.table rbindlist
load_data_file <- function(filename, optional = FALSE, quiet = FALSE) {
  assert_that(is.character(filename))
  assert_that(length(filename) == 1)
  assert_that(is.logical(optional))
  assert_that(is.logical(quiet))

  # Get the fully qualified file name (i.e., file path + file name)
  fqfn <- find_data_file(filename, optional = optional, quiet = quiet)
  # If it's a csv, use read.csv
  if(endsWith(fqfn, "csv")){
    x <- read.csv(fqfn, comment.char = COMMENT_CHAR, stringsAsFactors = FALSE, check.names = FALSE, na.strings = c("NA", ""))
    if(!quiet) cat("Loading CSV file", filename, "\n")
  }
  if(endsWith(fqfn, "yaml")){
    x <- yaml.load_file(fqfn)
    if(!quiet) cat("Loading YAML file", filename, "...\n")
  }
  return(x)
}

#' approx_fun
#'
#' \code{\link{approx}} (interpolation) for interpolating years in a dplyr pipeline.
#'
#' @param year Numeric year, in a melted (gathered) data frame
#' @param value Numeric value to interpolate
#' @param rule Rule to use; see \code{\link{approx}} and details
#' @details Rule=1: interpolate only; out of bounds -> missing values
#' Rule=2: out of bounds -> fixed extrapolation
#' @return Interpolated values.
#' @importFrom assertthat assert_that
#' @export
#' @examples
#' df <- data.frame(year = 1:5, value = c(1, 2, NA, 4, 5))
#' approx_fun(df$year, df$value, rule = 2)
approx_fun <- function(year, value, rule = 1) {
  assert_that(is.numeric(year))
  assert_that(is.numeric(value))

  if(rule == 1 | rule == 2 ) {
    tryCatch(stats::approx(as.vector(year), value, rule = rule, xout = year)$y,
             error=function(e) NA)
  }
}

#' Save data to a specified folder
#'
#' @param data the data object being saved. Can be a data frame or a list of data frames.
#' @param output_folder folder where to save the output
#' @param output_filename the name of the file being saved. Defaults to the name of the data frame, or the named
#' elements of a list of data frames
#' @details The folder should be one of the folders specified in init_paths()
#' @importFrom readr write_csv
#' @export
save_output <- function(data, output_folder, output_filename = NA, ...){
  # Figure out the directory where the output will be saved
  if( is.data.frame(data)){
    if(is.na(output_filename)){
      # If no output_filename is specified, default it to the name of the object plus ".csv"
      output_filename <- sprintf('%s.csv', deparse(substitute(data)))
    }
    fqfn <- paste0(output_folder, "/", output_filename)
    if(!endsWith(output_filename, ".csv")) fqfn <- paste0( fqfn, ".csv")
    write_csv(data, fqfn, col_names = TRUE)
  } else {
    if(is.list(data)){
      if(!is.na(output_filename)) print("Note: output_filename ignored as data object is a list")
      for(dataframe in names(data)){
        # Fully qualified file name is the output folder + the named dataframe in the list
        fqfn <- paste0(output_folder, "/", dataframe, ".csv")
        # Only write out data frames
        if( is.data.frame(data[[dataframe]])){
          write_csv(data[[dataframe]], fqfn, col_names = TRUE)
        }
      } # end for(dataframe in names(data))
    } #end if(is.list(data))
  } # end else
} #end function

#' repeat_add_columns
#'
#' Repeat a data frame for each entry in a second, binding the columns together.
#'
#' @param x Data frame to repeat
#' @param y A copy of \code{x} is created for each row of this data frame
#' @return A repeated \code{x} with columns from \code{y} added.
#' @details This function is used to repeat a table by specified values of a variable, written to a new column as
#'   necessary.
#' @importFrom assertthat assert_that
#' @examples
#' x <- tibble::tibble(x = 1:3)
#' y <- tibble::tibble(y = c(4, 5), z = c(6, 7))
#' repeat_add_columns(x, y)
repeat_add_columns <- function(x, y) {
  UNIQUE_JOIN_FIELD <- NULL           # silence package checks.
  assert_that(is.data.frame(x))
  assert_that(is.data.frame(y))

  x %>%
    mutate(UNIQUE_JOIN_FIELD = 1) %>%
    full_join(mutate(y, UNIQUE_JOIN_FIELD = 1), by = "UNIQUE_JOIN_FIELD") %>%
    select(-UNIQUE_JOIN_FIELD)
}
