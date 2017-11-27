# This is the main replication file for the paper results.

include("../../mimi-page.jl/src/getpagefunction.jl") # Needs modification specific for user

m = getpage()
run(m)

temp_df = DataFrame(
temp = m[:ClimateTemperature,:rt_g_globaltemperature])

adapt_df = DataFrame(m[:TotalAdaptationCosts,
:act_adaptationcosts_total])
preventative_costs = DataFrame(m[:TotalAbatementCosts, :tct_totalcosts])

slrdamages = DataFrame(m[:SLRDamages, :rcons_per_cap_SLRRemainGDP])
market_df = DataFrame(m[:MarketDamages, :rcons_per_cap_MarketRemainGDP])
nonmarket_df = DataFrame(m[:NonMarketDamages, :rcons_per_cap_NonMarketRemainGDP])

writetable("temp.csv", temp_df)
writetable("adapt.csv", adapt_df)
writetable("prevent.csv", preventative_costs)
writetable("slrdamages.csv", slrdamages)
writetable("marketdamages.csv", market_df)
writetable("nonmarketdamages.csv", nonmarket_df)


# This file + RCall -> ggplot
# Review test_mainmodel for which variables and to read in validation data
# Pop, GDP, emissions, Temp, damages
# Sum over regions

# Probabilistic Model title
