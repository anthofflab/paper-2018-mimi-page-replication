#this code makes table 1 in the main paper
include("src/mimi-page/test/test_mainmodel.jl") #run test of full main_model

tempcomp=abs((temp[10]-temp_compare[10])/temp_compare[10]*100)
gdpcomp=abs((vec(sum(gdp,2))[10]-vec(sum(gdp_compare,2))[10])/vec(sum(gdp_compare,2))[10]*100)
adaptcomp=abs((vec(sum(adaptation,2))[10]-vec(sum(adaptation_compare,2))[10])/vec(sum(adaptation_compare,2))[10]*100)
abatecomp=abs((vec(sum(abatement,2))[10]-vec(sum(abatement_compare,2))[10])/vec(sum(abatement_compare,2))[10]*100)
damagescomp=abs((damages[10,2]-damages_compare[10,2])/damages_compare[10,2]*100)
tecomp=abs((te-te_compare)/te_compare*100)

df = DataFrame([String,Float64],[:ModelVariable,:PercentDifference],0)
push!(df, ("Global Temperature in 2200", tempcomp))
push!(df, ("Global GDP in 2200", gdpcomp))
push!(df, ("Global Abatement Costs in 2200", abatecomp))
push!(df, ("Global Adaptation Costs in 2200", adaptcomp))
push!(df, ("US Per-Capita Consumption after All Damages in 2200", damagescomp))
push!(df, ("Total Effect", tecomp))

writetable(joinpath(@__DIR__, "../results/deterministiccomparison.csv"), df)
