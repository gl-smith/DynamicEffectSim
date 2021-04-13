
#----- Creates Custom ggplot Theme

dynamic_effect_gg_theme <- function(base_size = 14) {

  require(ggplot2)

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
