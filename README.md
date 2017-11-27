# Replication code for XXX et al. (XXX) "XXX"

This repository holds all code required to replicate the results of:

[TODO]

## Software requirements

You need to install [julia](http://julialang.org/) and [R](https://www.r-project.org/) to run the replication code.

## Preparing the software environment

On the julia side of things you need to install a number of packages. You can use the following julia code to do so:

````julia
Pkg.add("Mimi")
Pkg.add("DataFrames")
Pkg.add("RCall")
Pkg.add("ExcelReaders")
````

On the R side of things you also need to install a number packages. You can use the following R code to do so:

````R
install.packages("tidyverse")
````

## Cloning the repository

This git repository uses a git submodule. To ensure the submodule gets properly downloaded, make sure to use the
git ``--recurse-submodules`` option when cloning the repository. If you cloned the repository without that option,
you can issue the following two git commands to make sure the submodule is present on your system:
``git submodule init``, followed by ``git submodule update``.

## Running the replication script

To recreate all outputs for this paper, run the ``main.jl`` file in the folder ``src`` with this command:

````
julia src/main.jl
````

## Result files

All results will be stored in csv files in the folder ``results``. The following files will be created by running the main script.

## Result plots

All plots for the paper will be stored in the ``plots`` folder.