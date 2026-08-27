import CairoMakie
import LaTeXStrings: @L_str

CairoMakie.activate!()

function P₁(γ, T)
    return 5000γ / T
end

function P₂(γ, T)
    return 500 * (1 - 20γ - 10γ / T)
end


begin
    T = 5
    γgrid = range(0, inv(20 - 20 / (2T + 1) + 30 / T), 101)
    figure = CairoMakie.Figure()
    axis = CairoMakie.Axis(figure[1, 1], xlabel = L"\gamma", ylabel = "Points", title = L"Fines with $T=%$T$", limits = ((0, last(γgrid)), (0., 500.)))
    P₁fig = CairoMakie.lines!(axis, γgrid, γ -> P₁(γ, T))
    P₂fig = CairoMakie.lines!(axis, γgrid, γ -> P₂(γ, T))

    CairoMakie.Legend(figure[1, 2], [P₁fig, P₂fig], [L"P_1", L"P_2"])

    CairoMakie.save("paper/notes/experiment/figures/fine_T$T.png", figure)

    figure
end

# Preferred 
γ = 3 // 100
T = 5//1
P₁(γ, T)
P₂(γ, T)
