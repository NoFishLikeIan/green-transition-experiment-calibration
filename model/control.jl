function vfi!(Vₗ, dₗ, Vₗ₋₁, brownspace, p, mapping::Mapping; poltol = 1e-10)
    Ṽₗ₋₁ = linear_interp(brownspace, Vₗ₋₁)
    Ṽₗ = linear_interp(brownspace, Vₗ)
    n = length(Vₗ)

    dₗ[1] = zero(eltype(dₗ))

    @inbounds Threads.@threads for i in 2:n
        b = brownspace[i]
        obj = @closure d -> k(d, mapping) + p * Ṽₗ(b - d) + (1 - p) * Ṽₗ₋₁(b - d)

        Vᵢ, dᵢ = gss(obj, zero(b), b; tol = poltol)

        Vₗ[i] = Vᵢ
        dₗ[i] = dᵢ
    end

    return Vₗ, dₗ
end

function solvemodel!(V, d, brownspace, p, mapping::Mapping; niter = 101, optkwargs...)
    V .= P # Initial guess at penalty

    V₀ = [b > 0 ? P : 0. for b in brownspace] # v(b, 0) = P if b > 0

    for l in 1:netzero
        Vₗ = @view V[:, l]
        dₗ = @view d[:, l]

        Vₗ₋₁ = l > 1 ? (@view V[:, l - 1]) : V₀

        for iter in 1:niter
            vfi!(Vₗ, dₗ, Vₗ₋₁, brownspace, p, m; optkwargs...)
        end
    end

    return V, d
end
