% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/dsim_effect_plot.R
\name{dsim_effect_plot}
\alias{dsim_effect_plot}
\title{Simulates time series using univariate ARIMA models}
\usage{
dsim_effect_plot(
  dsim_object,
  plot_output = "treated_time_series",
  line_color = "darkblue",
  line_type = "dashed",
  line_size = 0.6
)
}
\arguments{
\item{dsim_object}{The output from \code{arima_ts_sim}.}

\item{plot_output}{Specifies which time series should be plotted on the y-axis. There are four possible options: \code{pointwise_effect}, \code{cumulative_effect}, \code{untreated_time_series}, and \code{treated_time_series}.}

\item{line_color}{Specifies the color of the output variable.}

\item{line_type}{Specifies the line type of the output variable.}

\item{line_size}{Specifies the line size of the output variable.}
}
\description{
This function plots the  simulated time series in \code{ggplot2}.
}
