using Test
using JuMP
using ProblemReductions
using SCIP

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

