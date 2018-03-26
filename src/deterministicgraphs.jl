include("mimi-page/src/getpagefunction.jl")

m = getpage()
run(m)
while m[:Discontinuity,:occurdis_occurrencedummy] != [0.,0.,0.,0.,0.,0.,0.,0.,0.,1.]
    run(m)
end

## Years
year = [2009, 2010, 2020, 2030, 2040, 2050, 2075, 2100, 2150, 2200]

## Population
pop = vec(sum(m[:Population,:pop_population], 2))
pop_compare = vec(sum(readpagedata(m,"mimi-page/test/validationdata/pop_population.csv"),2))
pop_df = DataFrame(year = year, MimiPAGE = pop, PAGE09 = pop_compare)

## GDP
gdp = vec(sum(m[:GDP,:gdp], 2))
gdp_compare = vec(sum(readpagedata(m,"mimi-page/test/validationdata/gdp.csv"), 2))
gdp_df = DataFrame(year = year, MimiPAGE = gdp, PAGE09 = gdp_compare)

## Emissions
emissions = m[:co2emissions,:e_globalCO2emissions]
emissions_compare = readpagedata(m,"mimi-page/test/validationdata/e_globalCO2emissions.csv")
emissions_df = DataFrame(year = year, MimiPAGE = emissions, PAGE09 = emissions_compare)

## Temperature
temp = m[:ClimateTemperature,:rt_g_globaltemperature]
temp_compare = readpagedata(m,"mimi-page/test/validationdata/rt_g_globaltemperature.csv")
temp_df = DataFrame(year = year, MimiPAGE = temp, PAGE09 = temp_compare)

## Damages
# Total climate damages
function getresidualdamages(model::Model)
  #function to calculate residual damages (i.e. undamaged gdp - damaged gdp) from a PAGE model
  #note - damaged GDP here includes adaptation, but not mitigation costs
  undamaged=model[:GDP,:gdp] #undamaged GDP in millions of dollars
  gdp_allcosts=model[:Discontinuity,:rcons_per_cap_DiscRemainConsumption]*1/(1-(model[:GDP,:save_savingsrate]/100)).*model[:Population,:pop_population] #GDP after all costs and damages in million dollars
  damaged=gdp_allcosts+model[:TotalAbatementCosts,:tct_totalcosts]+model[:TotalAdaptationCosts,:act_adaptationcosts_total]#add back in mitigation and adaptation costs to just get climate damagess
  undamaged-damaged
end
damages=getresidualdamages(m)
damages_compare=readpagedata(m,"mimi-page/test/validationdata/gdp.csv")-((readpagedata(m,"mimi-page/test/validationdata/rcons_per_cap_DiscRemainConsumption.csv")*1/(1-(m[:GDP,:save_savingsrate]/100)).*readpagedata(m,"mimi-page/test/validationdata/pop_population.csv"))+readpagedata(m,"mimi-page/test/validationdata/tct_totalcosts.csv")+readpagedata(m,"mimi-page/test/validationdata/act_adaptationcosts_tot.csv"))

damages_df = DataFrame(year = year, MimiPAGE = vec(sum(damages,2)), PAGE09 = vec(sum(damages_compare,2)))

## concentration
conc=m[:co2cycle,:c_CO2concentration]
conc_compare=readpagedata(m,"mimi-page/test/validationdata/c_co2concentration.csv")
conc_df=DataFrame(year = year, MimiPAGE = conc, PAGE09 = conc_compare)

###ADaptation Costs
adapt=vec(sum(m[:TotalAdaptationCosts,:act_adaptationcosts_total],2))
adapt_compare=vec(sum(readpagedata(m,"mimi-page/test/validationdata/act_adaptationcosts_tot.csv"),2))
adapt_df=DataFrame(year = year, MimiPAGE = adapt, PAGE09 = adapt_compare)


using RCall

R"library(tidyverse)"
# Population Plot
R"pop_df = $pop_df %>%
    gather(MimiPAGE, PAGE09, key = model, value = population)"
R"pop_plot = ggplot(pop_df, aes(x = year, y = population)) +
    geom_line(color = 'darkblue',lwd=1)+
    geom_point(aes(shape = model),size=3)+
    scale_shape_manual(values=c(1, 4),name='Model')+
    labs(y = 'Population (million persons)',
        x = 'Year')+theme_bw()"

# GDP Plot
R"gdp_df = $gdp_df %>%
    gather(MimiPAGE, PAGE09, key = model, value = gdp)"
R"gdp_plot = ggplot(gdp_df, aes(x = year, y = gdp)) +
    geom_line(color = 'darkblue',lwd=1)+
    geom_point(aes(shape = model),size=3)+
    scale_shape_manual(values=c(1, 4),name='Model')+
    labs(y = 'GDP (million USD)',
        x = 'Year')+theme_bw()"

# Temperature Plot
R"temp_df = $temp_df %>%
    gather(MimiPAGE, PAGE09, key = model, value = temperature)"
R"temp_plot = ggplot(temp_df, aes(x = year, y = temperature)) +
  geom_line(color = 'darkblue',lwd=1)+
  geom_point(aes(shape = model),size=3)+
  scale_shape_manual(values=c(1, 4),name='Model')+
    labs( y = 'Global Average Temperature (deg C Above Pre-Industrial)',
        x = 'Year')+theme_bw()"

# Emissions ggplot
R"emissions_df = $emissions_df %>%
    gather(MimiPAGE, PAGE09, key = model, value = emissions)"
R"ggplot(emissions_df, aes(x = year, y = emissions)) +
    geom_line(color = 'darkblue',lwd=1)+
    geom_point(aes(shape = model),size=3)+
    scale_shape_manual(values=c(1, 4),name='Model')+
    labs(y = 'Global CO2 Emissions (Mtons CO2)',
        x = 'Year')+theme_bw()"

# Damages Plot
R"tot_damages_df = $damages_df %>%
    gather(MimiPAGE, PAGE09, key = model, value = damages)"
R"tot_damages_plot = ggplot(tot_damages_df, aes(x = year, y = damages)) +
    geom_line(color = 'darkblue',lwd=1)+
    geom_point(aes(shape = model),size=3)+
    scale_shape_manual(values=c(1, 4),name='Model')+
    labs(y = 'Total Climate Damages (million USD)',
        x = 'Year')+theme_bw()"

#Concentration Plot
R"conc_df = $conc_df %>%
    gather(MimiPAGE, PAGE09, key = model, value = concentration)"
R"conc_plot = ggplot(conc_df, aes(x = year, y = concentration/1000)) +
    geom_line(color = 'darkblue',lwd=1)+
    geom_point(aes(shape = model),size=3)+
    scale_shape_manual(values=c(1, 4),name='Model')+
    labs(y = 'Atmospheric CO2 Concentration (ppm)',
        x = 'Year')+theme_bw()"

#Adaptation Plot
R"adapt_df = $adapt_df %>%
    gather(MimiPAGE, PAGE09, key = model, value = adaptation)"
R"adapt_plot = ggplot(adapt_df, aes(x = year, y = adaptation)) +
    geom_line(color = 'darkblue',lwd=1)+
    geom_point(aes(shape = model),size=3)+
    scale_shape_manual(values=c(1, 4),name='Model')+
    labs(y = 'Total Adaptation Costs (Million USD)',
        x = 'Year')+theme_bw()"
