#' Aggregate simmulated time series data by group
#'
#' @param data Data frame
#' @param agg_function
#' @param window_size The number of consecutive time intervals to group together.
#' @param drop_incomplete_window Drop groups that dont have a full window's worth of observations.

aggregate_sim_data <- function(data,
                               agg_function = "sum",
                               window_size = 7,
                               drop_incomplete_window = TRUE) {

  require(assertthat)
  require(tidyverse)

    assert_that(
      any(class(dsim_object) == "dyn-arima-sim"),
      msg = "The input to argument one must be of class dyn-arima-sim"
      )

    assert_that(
      is.integer(window_size),
      msg = "The input to the argument window_size must be an integer."
    )

  # Creates data frame grouped by specified time interval
  # Counts number of observations for each time window
  # Drops windows with incomplete observations if specified

  base_output <- tibble::as_tibble(data) %>%
    dplyr::mutate(time_interval = group_n_consec_rows(.)) %>%
    dplyr::group_by(time_interval) %>%
    dplyr::mutate(values_in_window = n())


  # Drops windows with incomplete observations if specified
  if(drop_incomplete_window == TRUE) {
    base_output <- dplyr::filter(base_output, values_in_window == window_size)
  }

  # Warns users if a window is incomplete
  if(min(base_output$values_in_window) < window_size) {
    warning("The output contains an incomplete window.")
  }

  if(agg_function == "sum") {
    final_output <- base_output %>%
      dplyr::summarise_at(vars(y0:cumulative_effect), sum) %>%
      dplyr::ungroup() %>%
      dplyr::rename(time = time_interval)
  }

  if(agg_function == "mean") {
    final_output <- base_output %>%
      dplyr::summarise_at(vars(y0:cumulative_effect), mean) %>%
      dplyr::ungroup() %>%
      dplyr::rename(time = time_interval)
  }

  final_output <- add_dsim_class(final_output)

  # Species how the data was aggregated
  output_specifications <-
    glue::glue("Aggregation function: {agg_function}. Periods in window = {window_size}.")

  print(output_specifications)
  return(final_output)

}
