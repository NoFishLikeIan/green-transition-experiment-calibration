function heatmapoverstatespace!(fig, brownspace, lspace, V; plotkwargs...)
    heatmap!(fig, brownspace, lspace, V'; xlabel = L"Brown capital $b$ TW", ylabel = L"Horizon $l$ years", yticks = lspace, plotkwargs...)

    return fig
end

heatmapoverstatespace(brownspace, lspace, V; kwargs...) = heatmapoverstatespace!(plot(), brownspace, lspace, V; kwargs...)

function browntrajectory(b₀, d, brownspace, lspace)
    bpath = [b₀]
    dpath = Float64[]

    for l in reverse(lspace)
        bₜ = isempty(bpath) ? b₀ : bpath[end]
        dₜ = linear_interp(brownspace, d[:, l], bₜ)
        bₜ₊₁ = bₜ - dₜ

        push!(dpath, dₜ)
        push!(bpath, bₜ₊₁)
    end

    return bpath, dpath
end

function simulatetrajectory(b₀, d, p, brownspace, netzero; maxiter = 1000)
    bpath = [b₀]
    dpath = Float64[]

    t = 0
    T = netzero
    bₜ = copy(b₀)
    while (bₜ > 1e-3) && (t < maxiter)
        if rand() < p T += 1 end

        t += 1
        l = T - t

        dₜ = (l > 0 && bₜ > 0) ? linear_interp(brownspace, d[:, l], bₜ) : 0.

        bₜ = bₜ - dₜ
        
        push!(bpath, bₜ)
        push!(dpath, dₜ)
    end
    
    return bpath, dpath, T
end