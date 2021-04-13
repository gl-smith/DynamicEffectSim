
<!-- README.md is generated from README.Rmd. Please edit that file -->

# DynamicEffectSim

<!-- badges: start -->

<!-- badges: end -->

DynamicEffectSim allows researchers to simulate and visualize dynamic
causal relationships using univariate ARIMA models. This tool makes it
possible to simulate interventions whose effects grow stronger or weaker
over time. The benefit of using ARIMA models is that they account for
autoregressive processes, moving averages, and seasonality. Future
versions of the package will also accommodate multivariate ARIMA models.

# Core Functions

DynamicEffectSim has two core functions.

  - `arima_ts_sim`: Simulates a time series with a time-varying
    intervention. The simulation includes both a treated and control
    counterfactual states.

  - `dsim_effect_plot`: Plots the time series using ggplot2. The user
    can specify whether they want to plot the treated time series, the
    untreated time series, the pointwise effect of the intervention, or
    the cumulative effect of the intervention.

## Installation

``` r
# install.packages("devtools")
library(devtools)
devtools::install_github("gl-smith/DynamicEffectSim")
```

## Example: Simulating a Treatment With an Attenuating Effect

This is a basic example which shows you how to simulate and plot a time
series with an intervention that attenuates over time. The results of
the simulation are stored as a tibble.

``` r

library(tidyverse)
library(assertthat)
library(DynamicEffectSim)

attenuating_effect <- 
arima_ts_sim(
  model = list(ar = 0.02),
  change_type = "attenuation",
  treat_start = 75,
  ts_length = 500,
  intercept = 4,
  effect = 10,
  delta = .05
) 

glimpse(attenuating_effect)
#> Rows: 500
#> Columns: 10
#> $ time              <int> 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, …
#> $ time_since_treat  <dbl> -74, -73, -72, -71, -70, -69, -68, -67, -66, -65, -…
#> $ post_treatment    <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, …
#> $ time_post_treat   <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, …
#> $ base_effect       <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, …
#> $ y0                <dbl> 4.296192, 3.699683, 4.160455, 2.151427, 5.836429, 3…
#> $ x1                <dbl> 4.513936, 3.528169, 4.205884, 2.904551, 4.620876, 3…
#> $ y1                <dbl> 4.296192, 3.699683, 4.160455, 2.151427, 5.836429, 3…
#> $ pointwise_effect  <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, …
#> $ cumulative_effect <dbl> 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, …
```

The `dsim_effect_plot` makes it easy to plot the simulated time series.
The default option returns a plot of the “treated” time series.

``` r
dsim_effect_plot(attenuating_effect)
```

<img src="man/figures/README-plot simulation-1.png" width="100%" />
