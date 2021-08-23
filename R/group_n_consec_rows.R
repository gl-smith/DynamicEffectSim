#' Create group IDs for specified number of consecutive rows in data frames
#'
#' @param data Data frame
#' @param group.size Number of consecutive rows to group together

group_n_consec_rows <- function(data, group.size = 7) {
  # + 1 ensures that the first group starts at 1
  ((1:nrow(data) - 1) %/% group.size) + 1
}
