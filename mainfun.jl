include("src/pkginstall.jl")
using BenchmarkTools, Plots, JLD2

include("src/formatteddata.jl")
include("src/renewableenergysimulation.jl")
include("src/showboundrycase.jl")
include("src/readdatafromexcel.jl")
include("src/cuccommitmentmodel.jl")
include("src/tuccommitmentmodel.jl")
include("src/casesploting.jl")
include("src/creatfrequencyconstraints.jl")
include("src/cluster_units.jl")
include("src/recognizingcriticalscenarios.jl")
include("src/simplifiedcuccommitmentmodel.jl")

UnitsFreqParam,
WindsFreqParam,
StrogeData,
DataGen,
GenCost,
DataBranch,
LoadCurve,
DataLoad = readxlssheet()

config_param, units, lines, loads, stroges, NB, NG, NL, ND, NT, NC = forminputdata(
	DataGen,
	DataBranch,
	DataLoad,
	LoadCurve,
	GenCost,
	UnitsFreqParam,
	StrogeData,
)

winds, NW = genscenario(WindsFreqParam, 1)

# NT = 24 * 7
rampingup_critical_scenario, frequency_critical_scenario = recognizing_critical_scenarios(winds, loads, NT)
# jldsave("/home/yuanyiping/下载/task 9/master-5/res/scenarios/scenaros5.jld2"; rampingup_critical_scenario, frequency_critical_scenario)

p1 = Plots.heatmap(
	rampingup_critical_scenario;
	c = cgrad([:white, :red]),
	# title = "critical scenarios for flexility-check",
	ylabel = "scenarios",
	xlabel = "time",
)
p2 = Plots.heatmap(
	frequency_critical_scenario;
	c = cgrad([:white, :blue]),
	#  title="critical scenarios for frequency-dynamics",
	ylabel = "scenarios",
	xlabel = "time",
)
Plots.plot(p1, p2; size = (800, 300), titlefontsize = 8, layout = (1, 2))

# f_base = 50.0
# RoCoF_max = 1.0
# f_nadir = 49.5
# f_qss = 49.5
# Δp = maximum(units.p_max[:, 1]) * 1.0
# Δp * f_base / RoCoF_max / 50 * 1.0

# # RoCoF constraint
# @constraint(
#     scuc,
#     [t = 1:NT],
#     (sum(winds.Mw[:, 1] .* winds.Fcmode[:, 1] .* winds.p_max[:, 1]) + 2 * sum(cunits.Hg[:, 1] .* cunits.p_max[:, 1] .* x[:, t]))
#     /
#     (sum(units.p_max[:, 1]) + sum(winds.Fcmode .* winds.p_max))
#     >=
#     Δp * f_base / RoCoF_max * 1.0
# )

NT = 24
@time p₀, pᵨ, pᵩ, seq_sr⁺, seq_sr⁻, su_cost, sd_cost, prod_cost, cost_sr⁺, cost_sr⁻ = scucmodel(
	NT,
	NB,
	NG,
	ND,
	NC,
	units,
	loads,
	winds,
	lines,
	config_param,
	rampingup_critical_scenario,
	frequency_critical_scenario,
)

cunits, cNG, cluster_cunitsset, cluster_featurematrix = calculating_clustered_units(units, DataGen, GenCost, UnitsFreqParam)

@time p₀, pᵨ, pᵩ, seq_sr⁺, seq_sr⁻, su_cost, sd_cost, prod_cost, cost_sr⁺, cost_sr⁻ = refined_cscucmodel(
	NT,
	NB,
	NG,
	cNG,
	ND,
	NC,
	units,
	cunits,
	loads,
	winds,
	lines,
	config_param,
	cluster_cunitsset,
	cluster_featurematrix,
	rampingup_critical_scenario,
	frequency_critical_scenario,
)

@time p₀, pᵨ, pᵩ, seq_sr⁺, seq_sr⁻, su_cost, sd_cost, prod_cost, cost_sr⁺, cost_sr⁻ = simfilied_cscucmodel(
	NT,
	NB,
	cNG,
	ND,
	NC,
	cunits,
	loads,
	winds,
	lines,
	config_param,
	rampingup_critical_scenario,
	frequency_critical_scenario,
)

plotcasestudies(
	p₀,
	pᵨ,
	pᵩ,
	seq_sr⁺,
	seq_sr⁻,
	su_cost,
	sd_cost,
	prod_cost,
	cost_sr⁺,
	cost_sr⁻,
	NT,
	NG,
	ND,
	NW,
	NC,
)
