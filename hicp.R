library(dplyr)
library(ggplot2)
library(lubridate)
library(readr)

theme_set(theme_minimal())

csv_url = "https://ec.europa.eu/eurostat/databrowser-backend/api/extraction/1.0/LIVE/true/sdmx/csv/PRC_HICP_MIDX?i&compressed=true"
df = read_csv(gzcon(url(csv_url)))

df = df |>
    mutate(date=ym(TIME_PERIOD)) |>
    select(date, unit, coicop, geo, HICP=OBS_VALUE)

# visualize HICP (harmonized index of consumer prices) over time
df |>
    filter(geo == "AT") |>  # Austria
    filter(unit == "I96") |>  # reference 100 is set to 1996
    filter(coicop == "CP00") |>  # all goods
    ggplot(mapping=aes(x=date, y=HICP)) +
    geom_line() +
    labs(x=NULL)

# visualize inflation over time (the derivative of HICP)
df |>
    filter(geo %in% c("AT", "DE", "ES")) |> 
    filter(unit == "I96") |>  # reference 100 is set to 1996
    filter(coicop == "CP00") |>  # all goods
    group_by(geo) |> 
    mutate(HICP12=lag(HICP, 12)) |>
    rowwise() |> 
    mutate(inflation=HICP / HICP12 * 100 - 100) |>
    ungroup() |> 
    ggplot(mapping=aes(x=date, y=inflation, color=geo)) +
    geom_line(linewidth=1) +
    geom_point() +
    labs(x=NULL, y="Inflation (%)") +
    scale_x_date(
        date_breaks="3 months",
        date_minor_breaks="1 month",
        date_labels="%b %y",
        limits=c(as.Date("2020-01-01"), NA)
    ) +
    scale_y_continuous(breaks=function(x, n) { floor(x[1]):ceiling(x[2]) })

# TODO: support data from countries like CH, where the data starts later than 1997

# coicop classification:
# 00. All-items (total or all-items index)  <-----------------------------------------------
# 01. Food and non-alcoholic beverages
# 02. Alcoholic beverages and tobacco
# 03. Clothing and footwear
# 04. Housing, water, electricity, gas and other fuels
# 05. Furnishings, Household equipment and routine maintenance of the house
# 06. Health
# 07. Transport
# 08. Communication
# 09. Recreation and culture
# 10. Education
# 11. Restaurants and hotels
# 12. Miscellaneous goods and services
