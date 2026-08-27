import CairoMakie
import LaTeXStrings: @L_str

CairoMakie.activate!()

function P₁(γ, T)
    r = 30γ / T
    return 500 * r / 3
end

function P₂(γ, T)
    r = 30γ / T
    y = (4T + 1) / (2T + 1)
    return 500 * (1 - r * y / 3)
end


begin
    T = 5
    γgrid = range(0, T / 30, 101)
    figure = CairoMakie.Figure()
    axis = CairoMakie.Axis(figure[1, 1], xlabel = L"\gamma", ylabel = "Points", title = L"Fines with $T=%$T$", limits = ((0, T / 30), (0., 500.)))
    P₁fig = CairoMakie.lines!(axis, γgrid, γ -> P₁(γ, T))
    P₂fig = CairoMakie.lines!(axis, γgrid, γ -> P₂(γ, T))

    CairoMakie.Legend(figure[1, 2], [P₁fig, P₂fig], [L"P_1", L"P_2"])

    CairoMakie.save("paper/notes/experiment/figures/fine_T$T.png", figure)

    figure
end

γ = 33 // 200
T = 5//1
P₁(γ, T)
P₂(γ, T)