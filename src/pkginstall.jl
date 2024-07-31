using Pkg
filepath = pwd()
Pkg.activate(filepath * "\\.pkg\\")

# is_installed_package = ["BenchmarkTools", "Distributions","Revise", "XLSX", "JuMP", "Gurobi", "PlotlyJS", "Plots", "MultivariateStats", "Clustering"]

# Pkg.add(is_installed_package)