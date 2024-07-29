# # Dining with Friends
# ## Invite your friends to a dinner party

# Suppose you are hosting a dinner party and you have invited your friends.
# The relation between your friends is represented by a graph.
# To create a graph, we use the `smallgraph` function from the `Graphs` package.
using ProblemReductions, Graphs, LuxorGraphPlot
graph = smallgraph(:petersen)

# We could make it into a maxcut problem, where each vertex stands for a person and the weight of edges 
# stand for the unfriendly level between them.
mc = MaxCut(graph,[3,2,4,2,1,-1,2,3,1,1,4,3,2,2,1])
# Then we use LuxorGraphPlot to visualize the graph.
show_graph(graph:svg)
# OK, since we wants to find the best partition for our friends, we should find the maximum cut of the graph.
# Then, we could reduce it into a spinglass problem,where we want to find the spins configuration with the lowest energy.

# ## Inviting friends to a dinner is harder than cracking the encryption system
# Intro to RSA encryption system
# Intro to factoring problem
# Example: how to solve $x \times y = 6$, by reducing to spin-glass
# arr = ProblemReductions.compose_multiplier(2, 2)
# ProblemReductions.set_output!(arr, [0, 1, 1, 0])  # ? x ? == 6


# NOTE: the first/second argument is the bit-width of the first/second input.
# TODO: visualize the spin-galss
# https://queracomputing.github.io/UnitDiskMapping.jl/notebooks/tutorial.html
# https://github.com/GiggleLiu/LuxorGraphPlot.jl
# https://arxiv.org/abs/2209.03965

