
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
