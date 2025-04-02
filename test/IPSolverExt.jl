using Test
using JuMP
using ProblemReductions
using SCIP
using Graphs

@testset "IPSolverExt" begin
    # Test exact_set_cover with HiGHS optimizer
    optimizer = SCIP.Optimizer
    nflavor = 5
    subsets = [[1, 2], [2, 3], [3, 4], [4, 5]]
    coverset = [1, 2, 3, 4, 5]

    # Test exact_set_cover with HiGHS optimizer
    Ext = Base.get_extension(ProblemReductions, :IPSolverExt)
    result = Ext.minimal_set_cover(coverset, subsets, optimizer)
    @test result == [1, 2, 4] || result == [1, 3, 4]
end

@testset "SetCovering" begin
    problem = SetCovering([[1, 2], [2, 3], [3, 4], [4, 5]], [1, 2, 3, 4])
    @test findmin(problem, IPSolver(SCIP.Optimizer,20,false)) == [1, 2, 4]
    @test findmax(problem, IPSolver(SCIP.Optimizer,20,false)) == [1, 2, 3, 4]
end

@testset "IPSolver" begin
    graph = smallgraph(:petersen)
    problem = MaximalIS(graph)
    @test findmin(problem, IPSolver(SCIP.Optimizer,20,false)) ∈ findmin(problem, BruteForce())

    problem = IndependentSet(graph)
    @test findmax(problem, IPSolver(SCIP.Optimizer,20,false)) ∈ findmax(problem, BruteForce())

    fact3 = Factoring(2, 1, 3)
    res3 = reduceto(CircuitSAT, fact3)
    problem = CircuitSAT(res3.circuit.circuit; use_constraints=true)
    @test findmin(problem, IPSolver(SCIP.Optimizer,20,false)) ∈ findmin(problem, BruteForce())
    best_config3 = findmin(problem, IPSolver(SCIP.Optimizer,20,false))
    assignment3 = Dict(zip(res3.circuit.symbols, best_config3))
    @test (2* assignment3[:p2]+ assignment3[:p1]) * assignment3[:q1] == 3

    m1 = Matching(graph)
    @test findmax(m1, IPSolver(SCIP.Optimizer,20,false)) ∈ findbest(m1, BruteForce())
end

@testset "Factoring" begin
    function factoring(m,n,N,solver)
        fact3 = Factoring(m, n, N)
        res3 = reduceto(CircuitSAT, fact3)
        problem = CircuitSAT(res3.circuit.circuit; use_constraints=true)
        vals = findmin(problem, IPSolver(solver,20,true))
        return ProblemReductions.read_solution(fact3, [vals[res3.p]...,vals[res3.q]...])
    end
    a,b = factoring(5,5,899,SCIP.Optimizer)
    @test a*b == 899
end