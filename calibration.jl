## Set-up
using Revise
using UnPack

using Optim

using Plots

Plots.default(size = 500 .* (√2, 1), dpi = 180)

## Model
includet("model/energy.jl")

## Baseline calibration
mediangreencosts = Cost(2.2, 22., 0.04)
medianbrowncost = Cost(1.05, 26., 0.025)

costs = (mediangreencosts, medianbrowncost)

# Capacity
totaleucapacity = 1.2 # TW
renewableshare = 0.32 # Share of renewable
g₀ = totaleucapacity * renewableshare
b₀ = totaleucapacity * (1 - renewableshare)
z = 1_313. # Energy demand in TWh

# Preliminary calibration, middle of the road Papageorgiou, Saam, Schulte (2017)  
α = 0.32
γ = 0.446
A = z / (α * g₀^γ + (1 - α) * b₀^γ)^(1 / γ)

energy = Energy(A, α, γ)

@assert F(g₀, b₀, energy) ≈ z
@assert F(G(b₀, z, energy), b₀, energy) ≈ z
## Implied costs
CostPair{T} = Tuple{Cost{T}, Cost{T}}
function grosscosts(d, b, z, energy::Energy, costs::CostPair)
    greencosts, browncosts = costs
    g = G(b, z, energy)
    g′ = G(b - d, z, energy) - (1 - greencosts.δ) * g

    return c(browncosts.δ * b - d, browncosts) + c(g′, greencosts)
end

function netcosts(d, b, z, energy, costs)
    grosscosts(d, b, z, energy, costs) - grosscosts(zero(d), b, z, energy, costs)
end