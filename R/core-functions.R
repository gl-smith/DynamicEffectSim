# Author: Gregory Smith
# Date: 5 - 5 - 2021
# Title: Aggregation Experiment R Functions

# To Do: Add the ability to export object as a time series object for use with CausalImpact

#----- Loads Packages

library(tidyverse)
library(assertthat)
library(broom)
library(ggplot2)
library(cowplot)

#----- Creates Custom ggplot Theme

aggregation_gg_theme <- function(base_size = 14) {
  theme_bw(base_size = base_size) %+replace%
    theme(
      plot.title = element_text(size = 17, face = "bold"), # , hjust = .5
      plot.subtitle = element_text(hjust = .5),
      legend.title = element_text(face = "bold"),
      plot.caption = element_text(hjust = .5, size = 11),
      axis.title = element_text(face = "bold"),
      strip.text.x = element_text(size = 14, face = "bold"),
      strip.text.y = element_text(size = 14, face = "bold"),
      strip.background = element_rect(fill = "white"),
      legend.position = "bottom"
    )
}


#----- Creates a Function To Simulate Time Series With Attenuating/Amplifying Effects

arima_ts_sim <-
  function(intercept = 0,
           noise_mean = 0,
           noise_sd = 1,
           effect = 0,
           ts_length = 200,
           treat_start = 75,
           coefficient_x1 = 1,
           change_type = "stasis",
           delta = 1,
           ...) {

    require(tidyverse)

    # Inputs Numeric?
    # Round Values (Add)
    # Add Amplification Ceiling

    # Test


    # Tests that Time Series Length > Time Series Start Time
    assert_that(ts_length > treat_start,
                msg = "The input to `ts_length` needs to be greater than the input to `treat_start`.")


    # Tests if `change_type` is supported
    input_check <- c("stasis", "attenuation", "amplification")

    assert_that(change_type %in% input_check,
                msg = "The input to `change_type` is not supported. Possible inputs include: `stasis`, `attenuation`, or `amplification`.")


    arima_args <- list(...)

    # Fits a Univariate ARIMA Model
    x1 <- intercept + arima.sim(arima_args, n = ts_length)
    y0 <- coefficient_x1 * x1 + rnorm(ts_length, mean = noise_mean, sd = noise_sd)

    raw_ts_data <- cbind(y0, x1)

    # Tidies the Output (Tibble of y0 and x1)
    tidy_ts_data <- as_tibble(raw_ts_data)

    # Calculates the Time Since Treatment (post-treat is only time since)
    time_data <- as_tibble(raw_ts_data) %>%
      mutate(
        time = row_number(),
        time_since_treat = time - treat_start,
        post_treatment = if_else(time > treat_start, 1, 0),
        time_post_treat = cumsum(post_treatment),
        base_effect = if_else(time > treat_start, effect, 0)
      ) %>%
      dplyr::select(time, time_since_treat, post_treatment, time_post_treat, base_effect)

    base_output_data <- bind_cols(time_data, tidy_ts_data)

    # Adds a Static, Attenuating, and Amplifying Effect
    if (change_type == "stasis") {
      final_output_data <- base_output_data %>%
        mutate(
          y1 = y0 + base_effect,
          pointwise_effect = y1 - y0,
          cumulative_effect = cumsum(pointwise_effect)
        )
    }

    # Multiplying by Post Treatment Ensures No "Pre-Treatment Effects" [0, 1]
    if (change_type == "attenuation") {
      final_output_data <- base_output_data %>%
        mutate(
          y1 = y0 + post_treatment*(effect - time_post_treat * delta),
          y1 = if_else(y1 < y0, as.numeric(y0), as.numeric(y1)),
          pointwise_effect = y1 - y0,
          cumulative_effect = cumsum(pointwise_effect)
        )
    }

    if (change_type == "amplification") {
      final_output_data <- base_output_data %>%
        mutate(
          y1 = y0 + post_treatment*(effect + time_post_treat * delta),
          pointwise_effect = y1 - y0,
          cumulative_effect = cumsum(pointwise_effect)
        )
    }

    class(final_output_data) <- c("tbl_df", "tbl", "data.frame", "dyn-arima-sim")

    return(final_output_data)

  }

#----- Creates a Function to Automatically Plot the Simulated Effects in ggplot

dsim_effect_plot <- function(dsim_object, plot_output = "treated_time_series") {

  require(assertthat)
  require(ggplot2)

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
  plot <- ggplot(dsim_object, aes(x = time)) + aggregation_gg_theme()

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

