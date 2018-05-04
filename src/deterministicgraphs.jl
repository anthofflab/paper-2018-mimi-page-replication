include("mimi-page/src/getpagefunction.jl")

m = getpage()
run(m)
while m[:Discontinuity,:occurdis_occurrencedummy] != [0.,0.,0.,0.,0.,0.,0.,0.,0.,1.]
    run(m)
end

## Years
year = [2009, 2010, 2020, 2030, 2040, 2050, 2075, 2100, 2150, 2200]

df_all = DataFrame(year=Int[], Model=String[], variable=String[], value=Float64[])

## Population
pop = vec(sum(m[:Population,:pop_population], 2))
pop_compare = vec(sum(readpagedata(m,"mimi-page/test/validationdata/pop_population.csv"),2))
append!(df_all, DataFrame(year=year, Model="Mimi-PAGE", variable="population", value=pop))
append!(df_all, DataFrame(year=year, Model="PAGE09", variable="population", value=pop_compare))

## GDP
gdp = vec(sum(m[:GDP,:gdp], 2))
gdp_compare = vec(sum(readpagedata(m,"mimi-page/test/validationdata/gdp.csv"), 2))
append!(df_all, DataFrame(year=year, Model="Mimi-PAGE", variable="gdp", value=gdp./1e6))
append!(df_all, DataFrame(year=year, Model="PAGE09", variable="gdp", value=gdp_compare./1e6))

## Temperature
temp = m[:ClimateTemperature,:rt_g_globaltemperature]
temp_compare = readpagedata(m,"mimi-page/test/validationdata/rt_g_globaltemperature.csv")
append!(df_all, DataFrame(year=year, Model="Mimi-PAGE", variable="temperature", value=temp))
append!(df_all, DataFrame(year=year, Model="PAGE09", variable="temperature", value=temp_compare))

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

append!(df_all, DataFrame(year=year, Model="Mimi-PAGE", variable="damages", value=vec(sum(damages,2))./1e6))
append!(df_all, DataFrame(year=year, Model="PAGE09", variable="damages", value=vec(sum(damages_compare,2))./1e6))

## concentration
conc=m[:co2cycle,:c_CO2concentration]./1000
conc_compare=readpagedata(m,"mimi-page/test/validationdata/c_co2concentration.csv")./1000
append!(df_all, DataFrame(year=year, Model="Mimi-PAGE", variable="co2conc", value=conc))
append!(df_all, DataFrame(year=year, Model="PAGE09", variable="co2conc", value=conc_compare))

###ADaptation Costs
adapt=vec(sum(m[:TotalAdaptationCosts,:act_adaptationcosts_total],2))
adapt_compare=vec(sum(readpagedata(m,"mimi-page/test/validationdata/act_adaptationcosts_tot.csv"),2))
append!(df_all, DataFrame(year=year, Model="Mimi-PAGE", variable="adaptcost", value=adapt./1e6))
append!(df_all, DataFrame(year=year, Model="PAGE09", variable="adaptcost", value=adapt_compare./1e6))

using RCall

R"""
library(tidyverse)

df <- $df_all

df$variable = factor(df$variable, levels=c('population','gdp','co2conc','temperature','damages', 'adaptcost'))

our_labeller <- as_labeller(c('population'='Population (million persons)',
    'gdp'='GDP (trillion USD)',
    'temperature'='Global Average Temperature (deg C Above Pre-Industrial)',
    'damages'='Total Climate Damages (trillion USD)',
    'co2conc'='Atmospheric CO2 Concentration (ppm)',
    'adaptcost'='Total Adaptation Costs (trillion USD)'))

ggplot(df, aes(x=year, y=value)) +
    geom_line(lwd=1) +
    geom_point(aes(shape=Model), size=3) +
    scale_shape_manual(values=c(1, 4), name='Model') +
    facet_wrap(~variable, scales="free_y", nrow=2, strip.position="left", labeller=our_labeller) +
    xlab('Year') +
    ylab(NULL) +
    theme_bw() +
    theme(strip.background = element_blank(),
        strip.placement = "outside",
        text = element_text(size=10),
        legend.position=c(0.485, 0.9), 
        legend.background = element_rect(fill="white", size=0.1, linetype="solid", colour ="black"))

ggsave("../results/figure2.pdf", width=6.5, units="in")
ggsave("../results/figure2.eps", width=6.5, units="in")
ggsave("../results/figure2.png", width=6.5, units="in")
"""
