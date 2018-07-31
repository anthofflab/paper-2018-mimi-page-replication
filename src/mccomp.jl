#this performs the monte-carlo comparison and plots figure 3 in the paper
using RCall

#this runs the Monte Carlo simulations it takes about 10 minutes
include("mimi-page/src/montecarlo.jl")
do_monte_carlo_runs(100000)

R"""
library(tidyverse)
source("Rallfun-v35.txt")

memory.limit(size=65536)

df_mimipage <- read_csv("mimi-page/output/mimipagemontecarlooutput.csv")
df_page <- read_csv("../data/PAGE09_mc_policya_100k.csv");

quants <- c(0.05,0.1,0.25,0.5,0.75,0.9,0.95)

n <- 100000

df_res_te <- qcomhdMC(df_mimipage$te[1:n]/1e6, df_page$te[1:n]/1e6, plotit=FALSE, q=quants)
df_res_tac <- qcomhdMC(df_mimipage$tac[1:n]/1e6, df_page$tac[1:n]/1e6, plotit=FALSE, q=quants)
df_res_tpc <- qcomhdMC(df_mimipage$tpc[1:n]/1e6, df_page$tpc[1:n]/1e6, plotit=FALSE, q=quants)
df_res_td <- qcomhdMC(df_mimipage$td[1:n]/1e6, df_page$td[1:n]/1e6, plotit=FALSE, q=quants)

df_res <- bind_rows(list(te=df_res_te,tac=df_res_tac,tpc=df_res_tpc,td=df_res_td), .id="variable")

df_res$variable = factor(df_res$variable, levels=c('td','tpc','tac','te'))

write_csv(df_res, "../results/quantilecomparison.csv")

our_labeller <- as_labeller(c('te'='Total Effect',
    'tac'='Total Adaptation Costs',
    'tpc'='Total Preventative Costs',
    'td'='Total Damages'))

ggplot(df_res, aes(q)) + 
    geom_hline(yintercept=0) +
    geom_pointrange(aes(y=est.1_minus_est.2, ymin=ci.low, ymax=ci.up), shape=4) + 
    facet_wrap(~variable, scales="free", nrow=2, labeller=our_labeller) +
    xlab('Quantile') +
    ylab('Mimi-PAGE - PAGE09 (trillion USD)') +
    theme_bw() +
    theme(strip.background=element_blank(),
        text=element_text(size=10),
        panel.grid.major=element_blank(),
        panel.grid.minor=element_blank())

ggsave("../results/figure3.pdf", width=6.5, units="in")
ggsave("../results/figure3.eps", width=6.5, units="in")
ggsave("../results/figure3.png", width=6.5, units="in")
"""
