# # Dining with Friends(developing yet)
# ---
# ## Inviting friends to dinner > cracking a bank encryption system
# Using this package, we could showcase the problem how inviting friends to a dinner party is harder than cracking a bank encryption system.Let's introduce some background knowledge
# ### Intor to RSA 
# RSA is a public-key cryptosystem. It's widely used in 

# ### Intro to factoring problem
# The factoring problem is to find the prime factors of a composite number. It's a pratically hard problem. 
# ### Reduction path from _Factoring_ to _MaxCut_
# explain how I could use the ProblemReductions.jl to reduce the factoring problem to the MaxCut problem

# ---
# ## Factoring -> MaxCut
using ProblemReductions, Graphs, LuxorGraphPlot

# ### Create a factoring problem
# Example: how to solve $x \times y = 6$, by reducing to spin-glass
# arr = ProblemReductions.compose_multiplier(2, 2)
# ProblemReductions.set_output!(arr, [0, 1, 1, 0]) ->? x ? == 6

# ### reduce the factoring to the circuit Sat problem
# could I visualize this circuit Sat?
# ### reduce the circuit Sat problem to the SpinGlass problem
# Visualize this SpinGlass problem
# ### reduce the SpinGlass problem to the MaxCut problem
# Visualize this MaxCut problem and explain how the maxcut problem represents inviting friends to a dinner party
