#this performs the monte-carlo comparison and plots figure 3 in the paper
using RCall

#this runs the Monte Carlo simulations it takes about 10 minutes
#if you don't want to wait for it to run you can find the output in the data folder of the paper replication
include("src/mimi-page/src/montecarlo.jl")
do_monte_carlo_runs(100000)

mc=readtable("src/mimi-page/output/mimipagemontecarlooutput.csv")
@rput mc
R"quants=apply(mc[,1:4],MARGIN=2,function (x) quantile(x, probs=c(0.05,0.1,0.25,0.5,0.75,0.9,0.95)))"
R"quantses=function(mcdata,q,alpha=0.05,n=100000){
  #mcdata is the raw monte carlo data
  #q is the desired quantile
  #alpha is the p-value (e.g. 0.05 for the 95% confidence interval)
  #n is the number of Monte Carlo runs

  #first order the monte carlo data
  mcdata=mcdata[order(mcdata)]
  l=qbinom(alpha/2,n,q)
  r=qbinom(1-alpha/2,n,q)+1
  return(c(mcdata[l],mcdata[r]))
}"
R"quantiles=c(0.05,0.1,0.25,0.5,0.75,0.9,0.95)"
R"quanterrors=array(dim=c(length(quantiles),2,4))"
R"for(i in 1:length(quantiles)){
  for(j in 1:4){
    quanterrors[i,,j]=quantses(mc[,j],quantiles[i])
  }
}"
R"dimnames(quanterrors)=list(c(quantiles),c('Lower','Upper'),colnames(quants))"
R"library(reshape2)"
R"quanterrors=dcast(melt(quanterrors),Var1+Var3~Var2)"
R"colnames(quanterrors)=c('Quantile','Variable','Lower','Upper')"
R"rownames(quants)=quantiles"
R"quants=melt(quants);colnames(quants)=c('Quantile','Variable','Estimate')"
R"quants=merge(quants,quanterrors)"

R"vars=c('td','tpc','tac','te')"
R"col=c('darkorange','darkblue','darkgoldenrod','darkorchid4')"
R"labs=c('Total Damages','Total Protection Costs','Total Adaptation Costs','Total Effect')"

excel=readtable("data/excel_page_mcresults.csv")
@rput excel
R"colnames(excel)=c('Variable',quantiles)"
R"excel=melt(excel);colnames(excel)=c('Variable','Quantile','PAGE09')"
R"quants=merge(quants,excel)"

R"x11()
par(mfrow=c(2,2))
for(i in 1:4){
  data=quants[which(quants$Variable==vars[i]),]
  plot(data$Quantile,(data$Estimate-data$PAGE09)/1e9,col=col[i],pch=18,cex=0.7,xlab='Quantile',ylab='Difference PAGE09 Value (Billions of Dollars)',main=labs[i],ylim=c(min(data$Lower-data$PAGE09)/1e9,max(data$Upper-data$PAGE09)/1e9))
  arrows(data$Quantile,(data$Lower-data$PAGE09)/1e9,data$Quantile,(data$Upper-data$PAGE09)/1e9,code=0,col=col[i])
  abline(h=0,col='black')
}"
