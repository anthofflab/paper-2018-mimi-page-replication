# This is the main replication file for the paper results.

include("../../mimi-page.jl/src/getpagefunction.jl") # Needs modification specific for user

m = getpage()
run(m)

## Years
year = [2009, 2010, 2020, 2030, 2040, 2050, 2075, 2100, 2150, 2200]

## Population
pop = vec(sum(m[:Population,:pop_population], 2))
pop_compare = vec(sum(readpagedata(m,"../mimi-page.jl/test/validationdata/pop_population.csv"),2))
pop_df = DataFrame(year = year, MimiPAGE = pop, PAGE09 = pop_compare)

## GDP
gdp = vec(sum(m[:GDP,:gdp], 2))
gdp_compare = vec(sum(readpagedata(m,"../mimi-page.jl/test/validationdata/gdp.csv"), 2))
gdp_df = DataFrame(year = year, MimiPAGE = gdp, PAGE09 = gdp_compare)

## Emissions
emissions = m[:co2emissions,:e_globalCO2emissions]
emissions_compare = readpagedata(m,"../mimi-page.jl/test/validationdata/e_globalCO2emissions.csv")
emissions_df = DataFrame(year = year, MimiPAGE = emissions, PAGE09 = emissions_compare)

## Temperature
temp = m[:ClimateTemperature,:rt_g_globaltemperature]
temp_compare = readpagedata(m,"../mimi-page.jl/test/validationdata/rt_g_globaltemperature.csv")
temp_df = DataFrame(year = year, MimiPAGE = temp, PAGE09 = temp_compare)

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

# Total damages
MimiPAGE_total = discdamages + slrdamages + mdamages + nmdamages
PAGE09_total = discdamages_compare + slrdamages_compare + mdamages_compare + nmdamages_compare

damages_df = DataFrame(year = year,
                        MimiPAGE_disc = discdamages, PAGE09_disc = discdamages_compare,
                        MimiPAGE_slr = slrdamages, PAGE09_slr = slrdamages_compare,
                        MimiPAGE_mkt = mdamages, PAGE09_mkt = mdamages_compare,
                        MimiPAGE_nonmkt = nmdamages, PAGE09_nonmkt = nmdamages_compare,
                        MimiPAGE = MimiPAGE_total, PAGE09 = PAGE09_total)

using RCall

R"library(tidyverse)"
# Population Plot
R"pop_df = $pop_df %>%
    gather(MimiPAGE, PAGE09, key = model, value = population)"
R"pop_plot = ggplot(pop_df, aes(x = year, y = population)) +
    geom_line(aes(color = model))+
    geom_point(aes(shape = model))+
    scale_shape_manual(values=c(6, 17))+
    labs(title = 'Comparing Mimi-PAGE and PAGE09',
        subtitle = 'Population',
        y = 'Population (million persons)',
        x = 'Year')"

# GDP Plot
R"gdp_df = $gdp_df %>%
    gather(MimiPAGE, PAGE09, key = model, value = gdp)"
R"gdp_plot = ggplot(gdp_df, aes(x = year, y = gdp)) +
    geom_line(aes(color = model))+
    geom_point(aes(shape = model))+
    scale_shape_manual(values=c(6, 17))+
    labs(title = 'Comparing Mimi-PAGE and PAGE09',
        subtitle = 'GDP',
        y = 'GDP (million USD)',
        x = 'Year')"

# Temperature Plot
R"temp_df = $temp_df %>%
    gather(MimiPAGE, PAGE09, key = model, value = temperature)"
R"temp_plot = ggplot(temp_df, aes(x = year, y = temperature)) +
    geom_line(aes(color = model)) +
    geom_point(aes(shape = model))+
    scale_shape_manual(values=c(6, 17))+
    labs(title = 'Comparing Mimi-PAGE and PAGE09',
        subtitle = 'Temperature',
        y = 'Temperature (deg C)',
        x = 'Year')"

# Emissions ggplot
R"emissions_df = $emissions_df %>%
    gather(MimiPAGE, PAGE09, key = model, value = emissions)"
R"ggplot(emissions_df, aes(x = year, y = emissions)) +
    geom_line(aes(color = model))+
    geom_point(aes(shape = model))+
    scale_shape_manual(values=c(6, 17))+
    labs(title = 'Comparing Mimi-PAGE and PAGE09',
        subtitle = 'Emissions',
        y = 'Emissions (tons CO2)',
        x = 'Year')"

# Damages Plot
R"tot_damages_df = $damages_df %>%
    gather(MimiPAGE, PAGE09, key = model, value = damages)"
R"tot_damages_plot = ggplot(tot_damages_df, aes(x = year, y = damages)) +
    geom_line(aes(color = model))+
    geom_point(aes(shape = model))+
    scale_shape_manual(values=c(6, 17))+
    labs(title = 'Comparing Mimi-PAGE and PAGE09',
        subtitle = 'Total Damages',
        y = 'Total Damages (million USD)',
        x = 'Year')"
