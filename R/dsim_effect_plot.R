
#' @title Simulates time series using univariate ARIMA models
#'
#' @description
#'
#' This function plots the  simulated time series in \code{ggplot2}.
#'
#' @param dsim_object The output from \code{arima_ts_sim}.
#'
#' @param plot_output Specifies which time series should be plotted on the y-axis. There are four possible options: \code{pointwise_effect}, \code{cumulative_effect}, \code{untreated_time_series}, and \code{treated_time_series}.
#'

dsim_effect_plot <- function(dsim_object, plot_output = "treated_time_series") {

  require(assertthat)
  require(ggplot2)

  # Add Ability to change color and line width defaults

  # Tests Class (Is it a Dynamic ARIMA Sim Object?)
  assert_that(any(class(dsim_object) == "dyn-arima-sim"),
              msg = "The input to argument one must be of class dyn-arima-sim")


  # Tests if `plot_output` input is specified correctly
  input_check <-
    c(
      "pointwise_effect",
      "cumulative_effect",
      "untreated_time_series",
      "treated_time_series"
    )

  assert_that(plot_output %in% input_check,
              msg = "The input to `plot_output` is not supported. Possible inputs include: `pointwise_effect`, `cumulative_effect`, `untreated_time_series`, `treated_time_series`.")


  # Initializes Plot
  plot <- ggplot(dsim_object, aes(x = time)) + dynamic_effect_gg_theme()

  # Adds a Horizontal Line at 0 on the Y axis
  plot <- plot + geom_hline(
    yintercept = 0,
    colour = "darkgrey",
    size = 0.8,
    linetype = "solid"
  )

  # Varies the Variable Displayed on the Y Axis
  if (plot_output == "pointwise_effect") {

    plot <- plot + geom_line(
      aes(y = pointwise_effect),
      dsim_object,
      size = 0.6,
      colour = "darkblue",
      linetype = "dashed",
      na.rm = TRUE
    )

  }

  if (plot_output == "cumulative_effect") {

    plot <- plot + geom_line(
      aes(y = cumulative_effect),
      dsim_object,
      size = 0.6,
      colour = "darkblue",
      linetype = "dashed",
      na.rm = TRUE
    )

  }

  if (plot_output == "untreated_time_series") {

    plot <- plot + geom_line(
      aes(y = y0),
      dsim_object,
      size = 0.6,
      colour = "darkblue",
      linetype = "dashed",
      na.rm = TRUE
    )

  }

  if (plot_output == "treated_time_series") {

    plot <- plot + geom_line(
      aes(y = y1),
      dsim_object,
      size = 0.6,
      colour = "darkblue",
      linetype = "dashed",
      na.rm = TRUE
    )

  }

  #  if (plot_output == "both_time_series") { }


  # Creates a Variable Name for the Y Axis
  y_axis_string <- as_label(plot_output) # Quotes the input as a label

  # Cleans the Y Axis String Name
  y_axis_string <- str_replace_all(y_axis_string, "_", " ")
  y_axis_string <- str_replace_all(y_axis_string, ":<NA>", " ")
  y_axis_string <- str_replace_all(y_axis_string, "[[:punct:]]", "") # Removes ""
  y_axis_string <- str_trim(y_axis_string, side = "both")
  y_axis_string <- str_to_title(y_axis_string)

  # Specifies the X and Y Axis Label Names
  plot <- plot + labs(x = "Time", y  = y_axis_string)

  return(plot)

}
