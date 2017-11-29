# This is the main replication file for the paper results.

include("../../mimi-page.jl/src/getpagefunction.jl") # Needs modification specific for user

m = getpage()
run(m)

## Years
year = [2009, 2010, 2020, 2030, 2040, 2050, 2075, 2100, 2150, 2200]

## Population
pop = m[:Population,:pop_population]
pop_compare = readpagedata(m,"../mimi-page.jl/test/validationdata/pop_population.csv")
pop_df = DataFrame(year = year, pop = sum(pop, 2), pop_compare = sum(pop_compare, 2))

## GDP
gdp = vec(sum(m[:GDP,:gdp], 2))
gdp_compare = vec(sum(readpagedata(m,"../mimi-page.jl/test/validationdata/gdp.csv"), 2))
gdp_df = DataFrame(year = year, gdp = gdp, gdp_compare = gdp_compare)

## Emissions
emissions = m[:co2emissions,:e_globalCO2emissions]
emissions_compare = readpagedata(m,"../mimi-page.jl/test/validationdata/e_globalCO2emissions.csv")
emissions_df = DataFrame(year = year, emissions = emissions, emissions_compare = emissions_compare)

## Temperature
temp = m[:ClimateTemperature,:rt_g_globaltemperature]
temp_compare = readpagedata(m,"../mimi-page.jl/test/validationdata/rt_g_globaltemperature.csv")
temp_df = DataFrame(year = year, temp = temp, temp_compare = temp_compare)

## Damages
# From Discontinuity
discdamages = m[:Discontinuity,:rcons_per_cap_DiscRemainConsumption]
discdamages_compare = readpagedata(m,"../mimi-page.jl/test/validationdata/rcons_per_cap_DiscRemainConsumption.csv")
damages_df = DataFrame(year = year, gdp = sum(gdp, 2), gdp_compare = sum(gdp_compare, 2))

# From SLR
slrdamages = m[:SLRDamages,:rcons_per_cap_SLRRemainConsumption]
slrdamages_compare = readpagedata(m, "../mimi-page.jl/test/validationdata/rcons_per_cap_SLRRemainConsumption.csv")

# Market damages
mdamages = m[:MarketDamages,:rcons_per_cap_MarketRemainConsumption]
mdamages_compare = readpagedata(m,"../mimi-page.jl/test/validationdata/rcons_per_cap_MarketRemainConsumption.csv")

# Non-Market Damages
nmdamages = m[:NonMarketDamages,:rcons_per_cap_NonMarketRemainConsumption]
nmdamages_compare = readpagedata(m,"../mimi-page.jl/test/validationdata/rcons_per_cap_NonMarketRemainConsumption.csv")

damages_df = DataFrame(year = year,
    discdamages = sum(discdamages, 2), discdamages_compare = sum(discdamages_compare, 2),
    slrdamages = sum(slrdamages, 2), slrdamages_compare = sum(slrdamages_compare, 2),
    mdamages = sum(mdamages, 2), mdamages_compare = sum(mdamages_compare, 2),
    nmdamages = sum(nmdamages, 2), nmdamages_compare = sum(nmdamages_compare, 2),
    total_damages = sum(discdamages, 2)+ sum(slrdamages, 2) + sum(mdamages, 2) + sum(nmdamages, 2),
    total_damages_compare = sum(discdamages_compare, 2) + sum(slrdamages_compare, 2) +
    sum(mdamages_compare, 2) + sum(nmdamages_compare, 2))

# Sum Damages
total_damages =

using RCall

R"library(tidyverse)"
# Population Plot

# GDP Plot

# Temperature Plot
R"temp_df = $temp_df %>% gather(temp, temp_compare, key = model, value = temperature)"
R"temp_plot = ggplot(temp_df, aes(x = year, y = temperature)) + geom_line(aes(color = model))"

# Emissions ggplot
R"emissions_df = $emissions_df %>% gather(emissions, emissions_compare, key = model, value = emissions)"
R"ggplot(emissions_df, aes(x = year, y = emissions)) + geom_line(aes(color = model))"

# Damages Plot

# Sum over regions

# Probabilistic Model title
