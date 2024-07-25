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

# ## Conclusion: Inviting friends is as hard as solving cryptographic problems