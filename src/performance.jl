using DataFrames

include("mimi-page/src/montecarlo.jl")

df = DataFrame([String,Bool,Int,Float64],[:model,:multithreading,:runs,:elapsed],0)

for i in (1_000, 10_000, 100_000)
    timing = do_monte_carlo_runs(i)

    push!(df, ("Mimi-PAGE", false, i, timing))
end

append!(df, readtable(joinpath(@__DIR__,"../data/excel-performance.csv")))

writetable(joinpath(@__DIR__, "../results/performance.csv"), df)
