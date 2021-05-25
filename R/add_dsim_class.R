add_dsim_class <-
  function(x) {
    output <- x
    class(output) <- c("tbl_df", "tbl", "data.frame", "dyn-arima-sim")
    return(output)
  }
