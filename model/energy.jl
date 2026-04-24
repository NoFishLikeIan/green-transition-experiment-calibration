struct Cost{T}
    p::T
    κ::T
    δ::T
end

@inline function c(φ, cost::Cost)
    cost.p * φ + cost.κ * φ^2 / 2 
end

struct Energy{T}
    A::T
    α::T
    γ::T
end

@inline function F(g, b, energy::Energy)
    @unpack γ, α, A = energy
    
    return A * (α * (g^γ) + (1 - α) * (b^γ))^(1 / γ)
end

@inline function G(b, z, energy::Energy)
    @unpack γ, α, A = energy

    z̃ = (z / A)^γ
    b̃ = (1 - α) * b^γ

    if z̃ < b̃
        return NaN
    else
        return (((z / A)^γ - (1 - α) * b^γ) / α)^(1 / γ)
    end
end