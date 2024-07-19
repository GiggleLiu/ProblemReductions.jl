"""
$TYPEDEF

The [cutting](https://queracomputing.github.io/GenericTensorNetworks.jl/dev/generated/MaxCut/) problem.
* In this problem, we would like to find the cut of the graph that maximizes the sum of the 
weights of the edges that are cut.

Positional arguments
-------------------------------
* `graph` is the problem graph.
* `edge_weights` are associated with the edges of the `graph`.
"""
struct MaxCut{WT1<:Union{UnitWeight, Vector}} <: AbstractProblem
    graph::SimpleGraph{Int}
    edge_weights::WT1
    function MaxCut(g::SimpleGraph,edge_weights::Union{UnitWeight, Vector}=UnitWeight()) 
        @assert edge_weights isa UnitWeight || length(edge_weights) == ne(g)
        new{typeof(edge_weights)}(g, edge_weights)
    end
end
Base.:(==)(a::MaxCut, b::MaxCut) = a.graph == b.graph && a.edge_weights == b.edge_weights

# varibles interface 
variables(gp::MaxCut) = [1:nv(gp.graph)...]
num_variables(gp::MaxCut) = nv(gp.graph)
flavors(::Type{<:MaxCut}) = [0, 1] #choose it or not
terms(gp::MaxCut) = [[[minmax(e.src,e.dst)...] for e in Graphs.edges(gp.graph)]...] 
# the weights of the edges should be input in the same order as they are in `terms(gp::MaxCut)`
                            
# weights interface
parameters(c::MaxCut) = [[c.edge_weights[i] for i=1:ne(c.graph)]...]
set_parameters(c::MaxCut, weights) = MaxCut(c.graph, weights[1:ne(c.graph)])



"""
    evaluate(c::MaxCut, config)
Compute the cut weights for the vertex configuration `config` (an iterator). The energy is the 
sum of the weights of the edges that are cut.
"""
function evaluate(c::MaxCut, config)
    @assert length(config) == nv(c.graph)
    cut_energy(terms(c), config; edge_weights=c.edge_weights)
end

function cut_energy(terms, config; edge_weights=UnitWeight())
    size = zero(promote_type(eltype(edge_weights)))
    for (i,j)in zip(terms,edge_weights)            # we have ensure that the edge_weights are in the same order as the edges in terms, so we could use zip()
        size += (config[i[1]] != config[i[2]]) * j # terms are the edges,and terms[1],terms[2] are the two vertices of the edge.
    end
    return size
end

"""
    findbest(c::MaxCut, method)
Find the best solution for the MaxCut problem using the `method`( BruteForce as default ).
The way to find the best config is different from that in `bruteforce.jl`. 

function findbest(c::MaxCut, ::BruteForce)
    best_size = -Inf
    best_configs = Vector{Int}[]
    for config in Iterators.product([flavors(c) for i in 1:num_variables(c)]...)
        size = Float64(evaluate(c, collect(config)))
        if size == best_size # if we find a new best solution, we add it to the list
            push!(best_configs, collect(config))
        elseif size > best_size[1] # use `>` to ensure it's a better configuration
            best_size = size
            empty!(best_configs)
            push!(best_configs, collect(config))
        end
    end
    return best_configs
end
"""