using NaNMath
using UnPack

struct Energy{T}
    A::T # Total productivity
    α::T # Green energy share
    γ::T # Elasticity of substitution
end

"CES energy production function"
function F(g, b, energy::Energy)
    @unpack γ, α, A = energy
    
    return A * (α * (g^γ) + (1 - α) * (b^γ))^(1 / γ)
end

"Implied green installed capacity"
function G(b, z, energy::Energy)
    @unpack γ, α, A = energy

    z̃ = (z / A)^γ
    b̃ = (1 - α) * b^γ

    base = ((z / A)^γ - (1 - α) * b^γ) / α
    exponent = inv(γ)

    return NaNMath.pow(base, exponent) # Returns NaN in case base < 0
end

struct Cost{T}
    p::T # Price of installed capacity
    κ::T # Adjustment costs of installed capacity
    δ::T # Depreciation of installed capacity
end

"Total costs of installed capacity"
function c(φ, cost::Cost)
    cost.p * φ + cost.κ * φ^2 / 2
end

struct Mapping{T, C <: NTuple{2, <: Cost{T}}, E <: Energy{T}}
    x₀::NTuple{2, T}
    energy::E
    costs::C
end

function k(d, mapping::Mapping)
    k(d, mapping.x₀, mapping.costs, mapping.energy)
end
function k(d, x, costs::NTuple{2, Cost}, energy::Energy)
	g, b = x	
	greencosts, browncosts = costs

	z = F(g, b, energy)

	ϕb = browncosts.δ * b
	ϕg = greencosts.δ * g

	c₀ = c(ϕb, browncosts) + c(ϕg, greencosts)

	b′ = ϕb - d
	g′ = G(b - d, z, energy) - (1 - greencosts.δ) * g
	
	return c(b′, browncosts) + c(g′, greencosts)
end;