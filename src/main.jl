# This is the main replication file for the paper results.
#Working directory should be "paper-mimi-page-replication/src"

#Table 1: % difference for deterministic Run
include("deterministiccomp.jl")

#Recreate Figure 2: Graphs of deterministic runs
include("deterministicgraphs.jl")

#Figure 3: Grapn of Monte Carlo run quantiles
include("mccomp.jl")

#Table 2: Speed comparison - note that this will differ from results presented in the paper
#Results in the paper are for an Intel Core i7-4770 @3.4 GHz CPU with 16GB of main memory
#Processing times on other systems will vary
include("performance.jl")
