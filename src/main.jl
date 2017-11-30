# This is the main replication file for the paper results.

include("../../mimi-page.jl/src/getpagefunction.jl") # Needs modification specific for user

m = getpage()
run(m)

## Years
year = [2009, 2010, 2020, 2030, 2040, 2050, 2075, 2100, 2150, 2200]

## Population
pop = vec(sum(m[:Population,:pop_population], 2))
pop_compare = vec(sum(readpagedata(m,"../mimi-page.jl/test/validationdata/pop_population.csv"),2))
pop_df = DataFrame(year = year, pop = pop, pop_compare = pop_compare)

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
discdamages = vec(sum(m[:Discontinuity,:rcons_per_cap_DiscRemainConsumption],2))
discdamages_compare = vec(sum(readpagedata(m,"../mimi-page.jl/test/validationdata/rcons_per_cap_DiscRemainConsumption.csv"),2))

# From SLR
slrdamages = vec(sum(m[:SLRDamages,:rcons_per_cap_SLRRemainConsumption],2))
slrdamages_compare = vec(sum(readpagedata(m, "../mimi-page.jl/test/validationdata/rcons_per_cap_SLRRemainConsumption.csv"),2))

# Market damages
mdamages = vec(sum(m[:MarketDamages,:rcons_per_cap_MarketRemainConsumption],2))
mdamages_compare = vec(sum(readpagedata(m,"../mimi-page.jl/test/validationdata/rcons_per_cap_MarketRemainConsumption.csv"),2))

# Non-Market Damages
nmdamages = vec(sum(m[:NonMarketDamages,:rcons_per_cap_NonMarketRemainConsumption],2))
nmdamages_compare = vec(sum(readpagedata(m,"../mimi-page.jl/test/validationdata/rcons_per_cap_NonMarketRemainConsumption.csv"),2))

damages_df = DataFrame(year = year,
    discdamages = discdamages, discdamages_compare = discdamages_compare,
    slrdamages = slrdamages, slrdamages_compare = slrdamages_compare,
    mdamages = mdamages, mdamages_compare = mdamages_compare,
    nmdamages = nmdamages, nmdamages_compare = nmdamages_compare,
    total_damages = discdamages + slrdamages + mdamages + nmdamages,
    total_damages_compare = discdamages_compare + slrdamages_compare + mdamages_compare + nmdamages_compare)

using RCall

R"library(tidyverse)"
# Population Plot
R"pop_df = $pop_df %>% gather(pop, pop_compare, key = model, value = population)"
R"pop_plot = ggplot(pop_df, aes(x = year, y = population)) + geom_line(aes(color = model))"

# GDP Plot
R"gdp_df = $gdp_df %>% gather(gdp, gdp_compare, key = model, value = gdp)"
R"gdp_plot = ggplot(gdp_df, aes(x = year, y = gdp)) + geom_line(aes(color = model))"

# Temperature Plot
R"temp_df = $temp_df %>% gather(temp, temp_compare, key = model, value = temperature)"
R"temp_plot = ggplot(temp_df, aes(x = year, y = temperature)) + geom_line(aes(color = model))"

# Emissions ggplot
R"emissions_df = $emissions_df %>% gather(emissions, emissions_compare, key = model, value = emissions)"
R"ggplot(emissions_df, aes(x = year, y = emissions)) + geom_line(aes(color = model))"

# Damages Plot
R"tot_damages_df = $damages_df %>% gather(total_damages, total_damages_compare, key = model, value = damages)"
R"tot_damages_plot = ggplot(tot_damages_df, aes(x = year, y = damages)) + geom_line(aes(color = model))"

# Probabilistic Model title
