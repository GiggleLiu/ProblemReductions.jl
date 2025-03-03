"""
$TYPEDEF 
    BinaryMatrixFactorization{K}(A::AbstractMatrix{Bool}, k::Int)

The Boolean Matrix Factorization (BMF) problem is defined on a binary matrix A in m x n size. Given a positive integer k, we need to determine whether we can factorize the matrix A into two binary matrices U and V such that the boolean product of U and V is equal to A, and the dimensions of U and V are (m x k) and (k x n) respectively. Refer to `Recent developments in boolean matrix factorization.(Miettinen, P., & Neumann, S,2020)` for details.

### Required interfaces
- [`variables`](@ref), the degrees of freedoms in the computational problem.
- [`flavors`](@ref), the flavors (domain) of a degree of freedom.
- [`solution_size`](@ref), the size (the lower the better) of the input configuration.
- [`problem_size`](@ref), the size of the computational problem. e.g. for a graph, it could be `(n_vertices=?, n_edges=?)`.

### Optional interfaces
- [`num_variables`](@ref), the number of variables in the computational problem.
- [`num_flavors`](@ref), the number of flavors (domain) of a degree of freedom.
- [`findbest`](@ref), find the best configurations of the input problem.
"""
struct BinaryMatrixFactorization<: AbstractProblem
    A::AbstractMatrix
    k::Int
    function BinaryMatrixFactorization(A::AbstractMatrix, k::Int) where K
        new(A, k)
    end
end
Base.:(==)(a::BinaryMatrixFactorization, b::BinaryMatrixFactorization) = a.A == b.A && a.k == b.k

variables(bmf::BinaryMatrixFactorization) = [1:size(bmf.A,1) * bmf.k + size(bmf.A,2) * bmf.k]
flavors(::Type{<:BinaryMatrixFactorization}) = (0, 1)
problem_size(bmf::BinaryMatrixFactorization) = (; num_rows=size(bmf.A,1), num_cols=size(bmf.A,2), k=bmf.k)
function solution_size(bmf::BinaryMatrixFactorization,b::AbstractMatrix,c::AbstractMatrix) 
   # Hamming Distance is used to described the solution size, the smaller the better
    return sum(bmf.A .!= boolean_product(b,c,bmf.k))
end

function boolean_product(A::AbstractMatrix, B::AbstractMatrix,k)
    @assert size(A,2) == size(B,1) == k "Dimension mismatch"
    @assert isbitstype(eltype(A)) && isbitstype(eltype(B)) "Only binary matrices are supported"
    C = zeros(size(A,1), size(B,2))
    for i in 1:size(A,1), j in 1:size(B,2)
        C[i,j] = any(x -> x==1,A[i,:] .* B[:,j])
    end
    return C 
end

energy_mode(::Type{<:BinaryMatrixFactorization}) = SmallerSizeIsBetter()

function is_binary_matrix_factorization(bmf::BinaryMatrixFactorization, b::AbstractMatrix, c::AbstractMatrix)
    return solution_size(bmf,b,c) == 0
end

"""
function findbest(bmf::BinaryMatrixFactorization, ::BruteForce)
    n_rows, n_cols = size(bmf.A)
    best = (fill(0, n_rows, bmf.k), fill(0, bmf.k, n_cols))
    best_energy = solution_size(bmf, best)
    for b in Iterators.product(fill(0:1, n_rows, bmf.k)...)
        for c in Iterators.product(fill(0:1, bmf.k, n_cols)...)
            energy = solution_size(bmf,best(1),best(2))
            if energy < best_energy
                best = (b,c)
                best_energy = energy
            end
        end
    end
    return best
end 
"""


