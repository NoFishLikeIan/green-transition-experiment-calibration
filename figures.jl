using Plots
using LaTeXStrings

include(joinpath(@__DIR__, "theory.jl"))

outputfig = contourf(
    capitalspace,
    capitalspace,
    (b, g) -> F(g, b, energy);
    ylabel = L"Green capacity $g$ TW",
    xlabel = L"Brown capacity $b$ TW",
    title = L"Energy output $z$ TWh",
    clims = (0, Inf),
    c = :viridis,
    margins = 5Plots.mm,
    xlims = extrema(capitalspace),
    ylims = extrema(capitalspace),
    levels = 31,
    aspect_ratio = 1,
)

isocolor = :white
plot!(
    outputfig,
    capitalspace,
    b -> G(b, z, energy::Energy);
    c = isocolor,
    linewidth = 4,
    label = L"F(g_0, b_0)",
    foreground_color_legend = nothing,
    background_color_legend = nothing,
    legendfontcolor = isocolor,
    legendfontsize = 11,
)
scatter!(outputfig, [b₀], [g₀]; c = isocolor, markersize = 5, label = L"(b_0, g_0)")

discontspace = range(0, b₀, 301)
maxc = c̃(b₀, (g₀, b₀), costs, energy)

phaseoutcostfig = plot(
    discontspace,
    d -> c̃(d, (g₀, b₀), costs, energy);
    xlabel = L"Decomissioned capital $d$ TW",
    c = :black,
    ylabel = L"Costs $c(d)$ bUSD",
    xlims = (0., b₀ * 1.04),
    ylims = (0, maxc * 1.04),
    linewidth = 3,
)

plot!(phaseoutcostfig, [b₀, b₀], [0, maxc]; linestyle = :dash, c = :darkred, linewidth = 3)
scatter!(
    phaseoutcostfig,
    [b₀],
    [maxc];
    linestyle = :dash,
    c = :darkred,
    label = L"Intiial brown capital $b_0$",
    legend = :left,
)
plot!(phaseoutcostfig, [0., b₀], [maxc, maxc]; linestyle = :dash, c = :darkred, linewidth = 3)

policyfig = heatmap(
    brownspace,
    lspace,
    d';
    xlabel = L"Brown capital $b$",
    ylabel = L"Horizon $l$",
    c = :Greens,
    title = L"$d(b, l)$",
    clims = (0, Inf),
    yticks = lspace,
)

trajectoryfig = plot(b⃗)
