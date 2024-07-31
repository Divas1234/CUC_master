using BenchmarkTools, Plots, JLD2

include("/home/yuanyiping/下载/task 9/master-5/src/formatteddata.jl")
include("/home/yuanyiping/下载/task 9/master-5/src/renewableenergysimulation.jl")
include("/home/yuanyiping/下载/task 9/master-5/src/showboundrycase.jl")
include("/home/yuanyiping/下载/task 9/master-5/src/readdatafromexcel.jl")
# include("/home/yuanyiping/下载/task 9/master-5/src/cuccommitmentmodel.jl")
# include("/home/yuanyiping/下载/task 9/master-5/src/tuccommitmentmodel.jl")
include("/home/yuanyiping/下载/task 9/master-5/src/casesploting.jl")
include("/home/yuanyiping/下载/task 9/master-5/src/creatfrequencyconstraints.jl")
include("/home/yuanyiping/下载/task 9/master-5/src/cluster_units.jl")
include("/home/yuanyiping/下载/task 9/master-5/src/recognizingcriticalscenarios.jl")
# include("/home/yuanyiping/下载/task 9/master-5/src/simplifiedcuccommitmentmodel.jl")
include("/home/yuanyiping/下载/task 9/master-5/tem/cuccommitmentmodel_bench.jl")
include("/home/yuanyiping/下载/task 9/master-5/tem/cuccommitmentmodel_pro.jl")

UnitsFreqParam, WindsFreqParam, StrogeData, DataGen, GenCost, DataBranch, LoadCurve, DataLoad = readxlssheet()

config_param, units, lines, loads, stroges, NB, NG, NL, ND, NT, NC = forminputdata(
    DataGen, DataBranch, DataLoad, LoadCurve, GenCost, UnitsFreqParam, StrogeData
)

if config_param.is_WindIntegration == 1
    winds, NW = genscenario(WindsFreqParam, 2)
end

NT = 24 * 1
rampingup_critical_scenario, frequency_critical_scenario = recognizing_critical_scenarios(winds, loads, NT)

# @time p₀, pᵨ, pᵩ, seq_sr⁺, seq_sr⁻, su_cost, sd_cost, prod_cost, cost_sr⁺, cost_sr⁻ = scucmodel(
#     NT, NB, NG, ND, NC, units, loads, winds, lines, config_param, rampingup_critical_scenario, frequency_critical_scenario)

cunits, cNG, cluster_cunitsset, cluster_featurematrix = calculating_clustered_units(units, DataGen, GenCost, UnitsFreqParam)

# @time p₀, pᵨ, pᵩ, seq_sr⁺, seq_sr⁻, su_cost, sd_cost, prod_cost, cost_sr⁺, cost_sr⁻ = refined_cscucmodel_withoutFreqandFlex(
#     NT, NB, NG, cNG, ND, NC, units, cunits, loads, winds, lines, config_param, cluster_cunitsset, cluster_featurematrix, rampingup_critical_scenario, frequency_critical_scenario)

@time p₀, pᵨ, pᵩ, seq_sr⁺, seq_sr⁻, su_cost, sd_cost, prod_cost, cost_sr⁺, cost_sr⁻ = refined_cscucmodel_withFreqandFlex(
    NT, NB, NG, cNG, ND, NC, units, cunits, loads, winds, lines, config_param, cluster_cunitsset, cluster_featurematrix, rampingup_critical_scenario, frequency_critical_scenario)

# @time p₀, pᵨ, pᵩ, seq_sr⁺, seq_sr⁻, su_cost, sd_cost, prod_cost, cost_sr⁺, cost_sr⁻ =  simfilied_cscucmodel(
#     NT, NB, cNG, ND, NC, cunits, loads, winds, lines, config_param, rampingup_critical_scenario, frequency_critical_scenario)

# plotcasestudies(p₀,pᵨ,pᵩ,seq_sr⁺,seq_sr⁻,su_cost,sd_cost,prod_cost,cost_sr⁺,cost_sr⁻,NT,NG,ND,NW,NC,)
