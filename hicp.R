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

df |>
    filter(geo == "AT") |>  # Austria
    filter(unit == "I96") |>  # reference 100 is set to 1996
    filter(coicop == "CP00") |>  # all goods
    ggplot(mapping=aes(x=date, y=HICP)) +
    geom_line() +
    labs(x=NULL)

df |>
    filter(geo == "AT") |>  # Austria
    filter(unit == "I96") |>  # reference 100 is set to 1996
    filter(coicop == "CP00") |>  # all goods
    mutate(HICP12=lag(HICP, 12)) |>
    rowwise() |> 
    mutate(inflation=HICP / HICP12 * 100 - 100) |>
    ungroup() |> 
    ggplot(mapping=aes(x=date, y=inflation)) +
    geom_line() +
    labs(x=NULL, y="Inflation (%)") +
    scale_x_date(date_breaks="1 year", date_labels="%y") +
    scale_y_continuous(breaks=function(x, n) { floor(x[1]):ceiling(x[2]) })

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
