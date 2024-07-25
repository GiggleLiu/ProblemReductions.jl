# #
# ## Invite your friends to a dinner party

using ProblemReductions

# Suppose you are hosting a dinner party and you have invited your friends.

# The relation between your friends is represented by a graph.
# To create a graph, we use the `smallgraph` function from the `Graphs` package.
using Graphs
graph = smallgraph(:petersen)

# This problem can be modeled as a maximum cut problem.
maxcut = MaxCut(graph)

# ## From maximum cut to spin glass

# ## From spin glass to circuit satisfiability

# ## From circuit satisfiability to cryptographic problems

# ## Inviting friends to a dinner is harder than cracking the encryption system
# Intro to RSA encryption system
# Intro to factoring problem
# Example: how to solve $x \times y = 6$, by reducing to spin-glass
arr = ProblemReductions.compose_multiplier(2, 2)
ProblemReductions.set_output!(arr, [0, 1, 1, 0])  # ? x ? == 6

# Spin-Glass to MaxCut (inviting friends to a dinner)

# NOTE: the first/second argument is the bit-width of the first/second input.
# TODO: visualize the spin-galss
# https://queracomputing.github.io/UnitDiskMapping.jl/notebooks/tutorial.html
# https://github.com/GiggleLiu/LuxorGraphPlot.jl
# https://arxiv.org/abs/2209.03965