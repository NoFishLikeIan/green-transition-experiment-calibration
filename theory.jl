## Imports
using Revise
using FastInterpolations, FastClosures
using Statistics

using Plots, LaTeXStrings
Plots.default(size = 500 .* (√2, 1), dpi = 180, linewidth = 2, label = false)

includet("model/energy.jl")
includet("model/control.jl")

includet("utils/plotting.jl")
includet("utils/optimisation.jl")

## Initial calibration
const greencosts = Cost(2.2, 22., 0.04)
const browncost = Cost(1.05, 26., 0.025)
const costs = (greencosts, browncost)

const totaleucapacity = 1.2 # TW

# Preliminary calibration, middle of the road Papageorgiou, Saam, Schulte (2017)  
const α = 0.32
const γ = 0.446

const g₀ = totaleucapacity * α
const b₀ = totaleucapacity * (1 - α)
const z = 1_313. # Energy demand in TWh

const A = z / (α * g₀^γ + (1 - α) * b₀^γ)^(1 / γ)

const energy = Energy(A, α, γ)
const x₀ = (g₀, b₀)
const mapping = Mapping(x₀, energy, costs)

## Solve
const netzero = 30

# p = 0 solutions
const dᶜ = b₀ / netzero
const controlcosts = netzero * k(dᶜ, x₀, costs, energy)
const maximalcosts = k(b₀, x₀, costs, energy)
const P = maximalcosts * (1 + 0.1)
const m = Mapping(x₀, energy, costs)

# p > 0 solution
p = 0.5
niter = p > 0 ? 101 : 1

n = 501
brownspace = range(0, b₀, n)
lspace = 1:netzero

# Value function solution
V = Array{Float64}(undef, length(brownspace), length(lspace))
d = similar(V)
solvemodel!(V, d, brownspace, p, mapping)

## Solve for various probabilities
pspace = [0.01, 0.05, 0.1]
Vp = Array{Float64}(undef, length(pspace), length(brownspace), length(lspace))
dp = similar(Vp)

for (pdx, p) in enumerate(pspace)
    print("Solving for p = $p, ($pdx / $(length(pspace)))\r")
    V = @view Vp[pdx, :, :]
    d = @view dp[pdx, :, :]

    solvemodel!(V, d, brownspace, p, mapping)
end


## Plot trajectories
pcolors = palette([:darkgreen, :darkred], length(pspace))

controltraj = [b₀ - (b₀ / netzero) * t for t in 0:netzero]
trajfig = plot(xlims = (0, netzero), xticks = 0:netzero, xlabel = L"Year $t$", ylabel = L"Excess brown capital $b_t - b^*$", legendtitle = L"p", ylims = (0, Inf))
for (pdx, p) in enumerate(pspace)
    d = @view dp[pdx, :, :]
    bpath, dpath = browntrajectory(b₀, d, brownspace, lspace)

    plot!(trajfig, 0:netzero, bpath .- controltraj; c  = pcolors[pdx], label = "$(100p)%")
end

trajfig

## Simulated trajectories
ntraj = 10_000

meantraj = Vector{Float64}[]
uppertraj = Vector{Float64}[]
lowertraj = Vector{Float64}[]
for (pdx, p) in enumerate(pspace)

    btraj = Vector{Float64}[]
    Ts = Int64[]

    for traj in 1:ntraj
        bpath, dpath, T = simulatetrajectory(b₀, d, p, brownspace, netzero)
        push!(btraj, bpath)
        push!(Ts, T)
    end

    Tmax = maximum(Ts)

    meanpath = Vector{Float64}(undef, Tmax)
    upperpath = Vector{Float64}(undef, Tmax)
    lowerpath = Vector{Float64}(undef, Tmax)
    for t in 1:Tmax
        bₜ = [ t ≤ lastindex(bpath) ? bpath[t] : 0. for bpath in btraj ]
    
        meanpath[t] = median(bₜ)
        upperpath[t] = quantile(bₜ, 0.9)
        lowerpath[t] = quantile(bₜ, 0.1)
    end

    push!(meantraj, meanpath)
    push!(uppertraj, upperpath)
    push!(lowertraj, lowerpath)
end


## Plot simulations
simfig = plot(xlims = (0, Inf), xlabel = L"Year $t$", ylabel = L"Brown capital $b_t$", ylims = (0, Inf), legendtitle = L"p")

for (pdx, p) in enumerate(pspace)
    meanpath = meantraj[pdx]
    T = length(meanpath)
    
    plot!(simfig, 1:T, meanpath; c = pcolors[pdx], label = "$(100p)%")
    plot!(simfig, 1:T, lowertraj[pdx]; fillrange = uppertraj[pdx], c = pcolors[pdx], label = false, alpha = 0.25, linewidth = 0.)

    simfig
end

simfig