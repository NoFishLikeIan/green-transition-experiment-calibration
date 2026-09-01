import CairoMakie
import LaTeXStrings: @L_str

CairoMakie.activate!()

function cost(d, γ, α)
    return γ * d^α
end

function penaltysum(W0, K0, γ, α)
    return W0 - cost(K0, γ, α)
end

function P₁(W0, K0, γ, α)
    return 2 * penaltysum(W0, K0, γ, α) / 5
end

function P₂(W0, K0, γ, α)
    return 3 * penaltysum(W0, K0, γ, α) / 5
end

function γmaximum(W0, K0, T, α)
    return min(2W0 / (2 + 5 * (1 / T^(α - 1) - 1 / (2T)^(α - 1))), W0 / (1 + 5 * (1 / (2T)^(α - 1) - 1 / (2T + 1)^(α - 1)))) / K0^α
end

function utilities(W0, K0, T, γ, α, interimpenalty, finalpenalty)
    return (
        W0 - 2T * cost(K0 / (2T), γ, α),
        W0 - T * cost(K0 / T, γ, α),
        W0 - interimpenalty - 2T * cost(K0 / (2T), γ, α),
        W0 - finalpenalty - (2T + 1) * cost(K0 / (2T + 1), γ, α),
        W0 - interimpenalty - finalpenalty - (2T + 1) * cost(K0 / (2T + 1), γ, α),
        W0 - interimpenalty - finalpenalty - cost(K0, γ, α)
    )
end

begin
    W0 = 1000
    K0 = 100
    α = 2
    γ = 1 // 20
    interimpenalty = P₁(W0, K0, γ, α)
    finalpenalty = P₂(W0, K0, γ, α)
    calibrations = map((5, 10)) do T
        payoffs = utilities(W0, K0, T, γ, α, interimpenalty, finalpenalty)
        γgrid = range(0, γmaximum(W0, K0, T, α), 101)

        # @assert interimpenalty == 200
        # @assert finalpenalty == 300
        # @assert all(payoffs[index] > payoffs[index + 1] for index in 1:(length(payoffs) - 1))
        # @assert payoffs[end] == 0

        figure = CairoMakie.Figure()
        axis = CairoMakie.Axis(figure[1, 1], xlabel = L"\gamma", ylabel = "Points", title = L"Penalties with $T=%$T$ and $\alpha=%$α$", limits = ((0, last(γgrid)), (0., W0)))
        P₁fig = CairoMakie.lines!(axis, γgrid, γvalue -> P₁(W0, K0, γvalue, α), color = :steelblue)
        P₂fig = CairoMakie.lines!(axis, γgrid, γvalue -> P₂(W0, K0, γvalue, α), color = :darkorange)
        CairoMakie.scatter!(axis, [γ, γ], [interimpenalty, finalpenalty], color = [:steelblue, :darkorange])
        CairoMakie.Legend(figure[1, 2], [P₁fig, P₂fig], [L"P_I", L"P_F"])

        CairoMakie.save("paper/notes/experiment/figures/fine_T$T.png", figure)

        (T = T, payoffs = payoffs, figure = figure)
    end

    calibrations
end
