using DataFrames
#this file contains code to run a speed test of multiple Monte Carlo runs against speeds of PAGE09 run in Excel
#PAGE09 was run on an an Intel Core i7-4770 @3.4 GHz CPU with 16GB of main memory
#care should be taken in comparing speeds from runs of Mimi-PAGE on different computers

include("mimi-page/src/montecarlo.jl")

df = DataFrame([String,Bool,Int,Float64],[:model,:multithreading,:runs,:elapsed],0)

for i in (1_000, 10_000)
    timing = do_monte_carlo_runs(i)

    push!(df, ("Mimi-PAGE", false, i, timing))
end

append!(df, readtable(joinpath(@__DIR__,"../data/excel-performance.csv")))

writetable(joinpath(@__DIR__, "../results/performance.csv"), df)
