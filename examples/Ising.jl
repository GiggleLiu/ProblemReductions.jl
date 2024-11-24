# # Solving Factoring problem with Ising machine
# ## Introduction  
# Ising machines are powerful tools for solving [`SpinGlass`](@ref) problem. Given that many NP problems 
# can be reduced to SpinGlass, it's possible to solve these NP problems with Ising machines.
# Among these problems, the [`Factoring`](@ref) problem is one of the most important problems and it's the 
# basis of RSA encryption system for its practical hardness.

# Therefore, solving Factoring problem with Ising machine is a significant task. In this example, we will show how to reduce 
# the Factoring problem to SpinGlass with `ProblemReductions.jl` and solve it with an Ising machine solver `GenericTensorNetworks.jl`
# 
# ## Factoring -> SpinGlass -> Ising machine
# Consider a simple Factoring problem: $6 = p \times q$, we need to figure out the prime factors of 6. 
# In our package, the Factoring problem is modeling under binary representation and when we initialize an instance, we need to offer the information of the number of bits for the two factors.
# Here, since 6 is a 3 bit number, the number of bits for the two factors are both 2.


# Run the following code in Julia REPL: 

using ProblemReductions, Graphs
factoring = Factoring(2, 2, 6) # initialize the Factoring problem

# Using [`reduction_graph`](@ref) and [`reduction_paths`](@ref), we could obtain the way to reduce Factoring to SpinGlass.  

g = reduction_graph() 
paths = reduction_paths(g,Factoring,SpinGlass)

# The input of `reduction_paths` is the reduction graph and the types of source and target problems. And the output 
# is a nested vector, each element of the outer vector is a path from source to target problem. 

# Then we could use [`reduceto`](@ref) to obtain the corresponding SpinGlass problem. 

reduction_result = implement_reduction_path(paths[1], factoring)
target = target_problem(reduction_result)

# Note that the output of `implement_reduction_path` is a [`AbstractReductionResult`](@ref), which contains the target problem and reduction information. So we 
# need to extract the target problem by [`target_problem`](@ref) function.

import GenericTensorNetworks, Graphs # import Ising machine solver
gtn_problem = GenericTensorNetworks.SpinGlass(
                  ProblemReductions.nv(target.graph),
                  vcat(ProblemReductions._vec.(Graphs.edges(target.graph)), [[i] for i=1:Graphs.nv(target.graph)]),
                  ProblemReductions.weights(target)
                )
result = GenericTensorNetworks.solve(
                    GenericTensorNetworks.GenericTensorNetwork(gtn_problem),
                    GenericTensorNetworks.SingleConfigMin()
                  )[] 

# Here we use `GenericTensorNetworks.jl` to solve the SpinGlass problem and obtain the `result`, we need to extract the solution for source problem from the result.

extract_solution(reduction_result, 1 .- 2 .* Int.(GenericTensorNetworks.read_config(result)))

# The result is `01` and `11`, decimally 2 and 3, which yields the correct factors of 6.

# ## Conclusion
# In this example, we show how to reduce Factoring problem to SpinGlass and solve it with Ising machine solver. This shows the power of `ProblemReductions.jl` in helping Problem Reduction.   
# 
# For your convenience, here is how to use `ProblemReductions.jl` to reduce source problem to target problem:
# - Initialize the source problem `source = SourceProblem(...) `.
# - Obtain the reduction paths `paths = reduction_paths(reduction_graph(), SourceProblem, TargetProblem)`.
# - Implement the reduction path `reduction_result = implement_reduction_path(paths[1], source)`.
# - Extract the target problem `target = target_problem(reduction_result)`.
