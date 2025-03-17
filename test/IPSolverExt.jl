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

using Graphs
graph = smallgraph(:petersen)
problem = MaximalIS(graph)
findmin(problem, IPSolver(SCIP.Optimizer,20,false))

@testset "HyperPoint" begin
    Ext = Base.get_extension(ProblemReductions, :IPSolverExt)
    point1 = Ext.HyperCubePoint((true,false,true))
    point2 = Ext.HyperCubePoint([true, false, true])
    @test point1 == point2

    @test length(Ext.all_points(3)) == 8
end

@testset "point_on_plane" begin
    Ext = Base.get_extension(ProblemReductions, :IPSolverExt)
    plane = Ext.HyperPlane((1.0, 2.0, -3.0), 1.0)
    @test Ext.point_on_plane(Ext.HyperCubePoint((true,false,false)), plane) == 0
    @test Ext.point_on_plane(Ext.HyperCubePoint((false,false,true)), plane) == -4
    @test Ext.point_on_plane(Ext.HyperCubePoint((false,true,false)), plane) == 1
end

@testset "HyperCubePlane" begin
    Ext = Base.get_extension(ProblemReductions, :IPSolverExt)
    p1 = Ext.HyperCubePoint((true,false,false))
    p2 = Ext.HyperCubePoint((false,false,true))
    p3 = Ext.HyperCubePoint((false,true,false))
    plane = Ext.HyperPlane([p1, p2, p3])
    @test Ext.point_on_plane(p1, plane) == 0
    @test Ext.point_on_plane(p2, plane) == 0
    @test Ext.point_on_plane(p3, plane) == 0

    p4 = Ext.HyperCubePoint((true,true,true))
    p5 = Ext.HyperCubePoint((false,false,false))
    p6 = Ext.HyperCubePoint((true,false,false))
    plane = Ext.HyperPlane([p4, p5, p6])
    @test Ext.point_on_plane(p4, plane) == 0
    @test Ext.point_on_plane(p5, plane) == 0
    @test Ext.point_on_plane(p6, plane) == 0

    p7 = Ext.HyperCubePoint((false,false,false))
    p8 = Ext.HyperCubePoint((false,true,false))
    p9 = Ext.HyperCubePoint((false,false,true))
    plane = Ext.HyperPlane([p7, p8, p9])
    @test Ext.point_on_plane(p7, plane) == 0
    @test Ext.point_on_plane(p8, plane) == 0
    @test Ext.point_on_plane(p9, plane) == 0

    p7 = Ext.HyperCubePoint((false,false,false))
    p8 = Ext.HyperCubePoint((true,true,false))
    p9 = Ext.HyperCubePoint((true,true,true))
    plane = Ext.HyperPlane([p7, p8, p9])
    @test Ext.point_on_plane(p7, plane) ≈ 0
    @test Ext.point_on_plane(p8, plane) ≈ 0 atol = 1e-8
    @test Ext.point_on_plane(p9, plane) ≈ 0 atol = 1e-8

    # HyperCubePoint{4}[(0000), (1000), (0100), (1100)]
    p1 = Ext.HyperCubePoint((false,false,false,false))
    p2 = Ext.HyperCubePoint((true,false,false,false))
    p3 = Ext.HyperCubePoint((false,true,false,false))
    p4 = Ext.HyperCubePoint((true,true,false,false))
    plane = Ext.HyperPlane([p1, p2, p3, p4])
    @test isnothing(plane)
end

@testset "HyperCubePlaneCut" begin
    Ext = Base.get_extension(ProblemReductions, :IPSolverExt)
    p4 = Ext.HyperCubePoint((true,true,true))
    p5 = Ext.HyperCubePoint((false,false,false))
    p6 = Ext.HyperCubePoint((true,false,false))
    plane = Ext.HyperPlane([p4, p5, p6])
    pl = Ext.all_points(3)
    hc = Ext.HyperCubePlaneCut(plane,pl)
    @test hc.on == [1,2,7,8]
    @test hc.above == [5,6]
    @test hc.below == [3,4]
end