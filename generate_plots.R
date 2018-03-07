library(ggplot2)
library(dplyr)

## Scatter plot example
dat <- data.frame(x = rnorm(1000), y = rnorm(1000), z = sample(-20:20, 1000, TRUE))
p <- ggplot(dat, aes(x, y, colour = z)) + geom_point()
p + scale_colour_gradient2(mid = "#1424C6", high = "#FA903E", low = "#0099F9") + theme_bw() -> scatter

scatter
ggsave("assets/scatter.png")

ggplot_build(scatter) -> g

sorted_colors <- data.frame(colors = g$data[[1]]$colour, z = dat$z) %>%
  distinct() %>%
  arrange(z) %>%
  pull(colors)

## Hex example
ggplot(data.frame(x = rnorm(10000), y = rnorm(10000)), aes(x = x, y = y)) +
  geom_hex() + coord_fixed() +
  scale_fill_gradientn(colours = sorted_colors) + theme_bw()

ggsave("assets/hex.png")

## Unemployment map example
unemp <- read.csv("http://datasets.flowingdata.com/unemployment09.csv",
                  header = FALSE, stringsAsFactors = FALSE)
names(unemp) <- c("id", "state_fips", "county_fips", "name", "year",
                  "?", "?", "?", "rate")
unemp$county <- tolower(gsub(" County, [A-Z]{2}", "", unemp$name))
unemp$county <- gsub("^(.*) parish, ..$","\\1", unemp$county)
unemp$state <- gsub("^.*([A-Z]{2}).*$", "\\1", unemp$name)

county_df <- map_data("county", projection = "albers", parameters = c(39, 45))

names(county_df) <- c("long", "lat", "group", "order", "state_name", "county")
county_df$state <- state.abb[match(county_df$state_name, tolower(state.name))]
county_df$state_name <- NULL

state_df <- map_data("state", projection = "albers", parameters = c(39, 45))

choropleth <- merge(county_df, unemp, by = c("state", "county"))
choropleth <- choropleth[order(choropleth$order), ]

ggplot(choropleth, aes(long, lat, group = group)) +
  geom_polygon(aes(fill = rate), colour = alpha("white", 1 / 2), size = 0.2) +
  geom_polygon(data = state_df, colour = "white", fill = NA) +
  coord_fixed() +
  theme_minimal() +
  ggtitle("US unemployment rate by county") +
  theme(axis.line = element_blank(), axis.text = element_blank(),
        axis.ticks = element_blank(), axis.title = element_blank()) +
  scale_fill_gradient2(mid = "#1424C6", high = "#FA903E", low = "#0099F9", midpoint = 9) 

ggsave("assets/map.png")

p <- ggplot(mtcars, aes(wt, mpg))
p + geom_point(size = 4, aes(colour = factor(cyl))) +
  scale_color_manual(values = c("#1424C6", "#0099F9","#FA903E")) +
  theme_bw()

ggsave("assets/simple_categoric.png")
