

#' @title Simulates time series using univariate ARIMA models
#'
#' @description
#'
#' This function simulates time series and allows users to add interventions
#' whose effects vary over time. The function returns a tibble.
#'
#'
#' @param intercept The starting y-intercept value for the time series.
#'
#' @param noise_mean The average value of random noise that should be added to the time series.
#'
#' @param noise_sd The standard deviation of random noise that should be added to the time series.
#'
#' @param x1_noise_mean The average value of to random noise that should be added when simulating x1.
#'
#' @param x1_noise_sd The standard deviation of random noise that should be added when simulating x1.
#'
#' @param effect The initial effect of the intervention.
#'
#' @param effect_ceiling The maximum value for the pointwise effect of a policy. This argument only works when \code{change_type = "amplification"}.
#'
#' @param ts_length The length of the simulated time period.
#'
#' @param treat_start The time that the intervention begins.
#'
#' @param coefficient_x1 Scales the value of x1.
#'
#' @param change_type Specifies the way that the treatment should change over time. Possible inputs are \code{stasis}, \code{attenuation}, and \code{amplification}.
#'
#' @param delta Specifies that rate that the effect of the treatment changes.
#'
#' @param round_to_integers Should the simulated values be rounded to integers?
#'
#' @param seed Sets the random seed.

arima_ts_sim <-
  function(intercept = 0,
           noise_mean = 0,
           noise_sd = 1,
           x1_noise_mean = 0,
           x1_noise_sd = 1,
           effect = 0,
           effect_ceiling = Inf, # Only works for policies with amplifying effects
           ts_length = 200,
           treat_start = 75,
           coefficient_x1 = 1,
           change_type = "stasis",
           delta = 1,
           round_to_integers = FALSE,
           seed = 175,
           ...) {

    require(tidyverse)
    require(assertthat)

    set.seed(seed)

    # Inputs Numeric?
    # Round Values (Add)
    # Add Amplification Ceiling

    # Tests that Time Series Length > Time Series Start Time
    assert_that(ts_length > treat_start,
                msg = "The input to `ts_length` needs to be greater than the input to `treat_start`.")


    # Tests if `change_type` is supported
    input_check <- c("stasis", "attenuation", "amplification")

    assert_that(change_type %in% input_check,
                msg = "The input to `change_type` is not supported. Possible inputs include: `stasis`, `attenuation`, or `amplification`.")


    arima_args <- list(...)

    # Fits a Univariate ARIMA Model
    x1 <- intercept + arima.sim(arima_args, n = ts_length, mean = noise_mean, sd = noise_sd)
    y0 <- coefficient_x1 * x1 + rnorm(ts_length, mean = x1_noise_mean, sd = x1_noise_sd)

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
          y1 = if_else(y1 < y0, y0, y1),
          pointwise_effect = y1 - y0,
          cumulative_effect = cumsum(pointwise_effect)
        )
    }

    if (change_type == "amplification") {
      final_output_data <- base_output_data %>%
        mutate(
          y1 = y0 + post_treatment*(effect + time_post_treat * delta),
          y1 = if_else(y1 > effect_ceiling, y0 + effect_ceiling, y1),
          pointwise_effect = y1 - y0,
          cumulative_effect = cumsum(pointwise_effect)
        )
    }


    if (round_to_integers == "TRUE") {
      final_output_data <- final_output_data %>%
        mutate_at(c("y0", "x1", "y1", "pointwise_effect", "cumulative_effect"), round)
    }

    class(final_output_data) <- c("tbl_df", "tbl", "data.frame", "dyn-arima-sim")

    return(final_output_data)

  }


library(tidyverse)

arima_ts_sim(
  model = list(ar = 0.02),
  change_type = "amplification",
  ts_length = 500,
  intercept = 4,
  effect = 10,
  delta = .05,
  round_to_integers = TRUE
)
