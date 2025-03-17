
struct HyperCubePoint{N}
    x::NTuple{N, Bool}
end
Base.show(io::IO, ::MIME"text/plain", hcp::HyperCubePoint) = show(io, hcp)
function Base.show(io::IO, hcp::HyperCubePoint)
    print(io, "(")
    for i in 1:length(hcp.x)
        print(io, hcp.x[i] ? 1 : 0)
    end
    print(io, ")")
end
function HyperCubePoint(iter)
    return HyperCubePoint(ntuple(i->iter[i], length(iter)))
end
Base.:(==)(a::HyperCubePoint, b::HyperCubePoint) = (a.x == b.x)

struct HyperPlane{N}
    coefficients::NTuple{N, Float64}
    offset::Float64
end

struct HyperPlaneInequality{N}
    hp::HyperPlane{N}
    symb::Int # 1: <=, 2: >=, 3: < , 4: >
end

struct HyperCubePlaneCut{N}
    hp::HyperPlane{N}
    above::Vector{Int}
    below::Vector{Int}
    on::Vector{Int}
end

function HyperCubePlaneCut(hp::HyperPlane{N}, points::Vector{HyperCubePoint{N}};atol = 1e-8) where {N}
    above = Int[]
    below = Int[]
    on = Int[]
    for (i, point) in enumerate(points)
        value = point_on_plane(point, hp)
        if value > atol
            push!(above, i)
        elseif value < -atol
            push!(below, i)
        else
            push!(on, i)
        end
    end
    return HyperCubePlaneCut(hp, above, below, on)
end

function point_on_plane(point::HyperCubePoint{N}, plane::HyperPlane{N}) where {N}
    return sum(point.x[i] * plane.coefficients[i] for i in 1:N) - plane.offset
end

function HyperPlane(points::Vector{HyperCubePoint{N}}) where {N}
    @assert length(points) == N
    A =  mapreduce(i-> collect(i.x),hcat,points)'
    if rank(A) == N
        return HyperPlane(((A \ ones(N))...,),1.0)
    elseif rank(A) == N-1
        q,r = qr(A)
        # display(r)
        i = findfirst(x -> abs.(x) .< 1e-10, diag(r))
        j = findfirst(vec(all(x -> abs.(x) .< 1e-10,r, dims=2)))
        if isnothing(j)
            j = N
        end
        r[j,i] = 1.0
        b = zeros(N)
        b[j] = 1.0
        # display(r)
        # display(b)
        return HyperPlane(((r \ b)...,),0.0)
    else
        return nothing
    end
end

function all_points(N::Int)
    return [HyperCubePoint([i & (1 << j) != 0 for j in 0:N-1]) for i in 0:2^N-1]
end

function all_cuts_points(N::Int)
    points = all_points(N)
    cuts = HyperCubePlaneCut[]
    for c in combinations(1:2^N,N)
        tag = 0
        for cut in cuts
            if c ⊆ cut.on
                tag = 1
                continue
            end
        end
        if tag == 1
            continue
        end
        hp = HyperPlane(points[c])
        if isnothing(hp)
            continue
        end
        push!(cuts, HyperCubePlaneCut(hp, points))
    end
    return cuts
end


function all_sets_cuts(N::Int)
    cuts = all_cuts_points(N)
    sets = Vector{Vector{Int}}()
    hps = HyperPlaneInequality{N}[]
    for cut in cuts
        for (i,set) in enumerate([cut.above, cut.below, cut.on ∪ cut.above, cut.on ∪ cut.below])
            set = sort(set)
            if set ∈ sets || isempty(set)
                continue
            else
                push!(sets, set)
                push!(hps, HyperPlaneInequality{N}(cut.hp,i))
            end
        end
    end
    return sets,hps
end
