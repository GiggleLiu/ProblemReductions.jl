# # Use Ising machines to crack RSA encryption system
# ---
# ## 
# Using this package, we could reduce the factoring problem to the spin glass problem and thereby use Ising machines to help crack RSA encryption systems.

# ### Intro to RSA 
# RSA is a public-key cryptosystem. It's widely used in encryption algorithm that helps secure bank transactions and communications. 
# Here's detailed introduction->[RSA encryption](https://en.wikipedia.org/wiki/RSA_(cryptosystem)). Easily explained, there are public key $(n,e)$ and private key$(n,d)$. 
# The attacker needs to factorize the $n$, a product of two large prime numbers. So the security of RSA derives from factoring problem.
# ### Factoring problem
# The factoring problem is to find the prime factors of a composite number. It's a pratically hard problem. One might say that for a large number n, with size of $10^{14}$, it's hard to factorize it.
# we could use Brute force method to search from $2$ to $\sqrt{n}$ and within 1 second, the answer is there.
# However, generally, the size of input(two large prime number) in RSA is 2048 bits.
# Consider two algorithms to solve it: General number field sieve(GNFS, a good algorithm in factoring) and  Brute force. 

# | Algorithm | Time complexity | Operations | Time ($10^{12}$ ops/s)  |
# | :--- | :--- | :--- | :--- | 
# | GNFS | $O(e^{(\log n)^{1/3}(\log \log n)^{2/3}})$ | $2^{112}$ | $≈ 7 \times 10^{20}$ years |
# | Brute force | $O(\sqrt{n})$ | $2^{1024}$|$≈5.7 \times 10^{228}$ years |
# Both are way longer than the age of our universe.So basically, factoring is pratically hard and RSA relies on its hardness.
# ### Ising model 
# Ising model is a mathematical model of ferromagnetism, which simulates a bunch of spins that interact with each other and sometimes contains a magnetic field.
# The hamiltonian（energy function) of Ising model is

# $H = \sum_{i,j}J_{ij}\sigma_i\sigma_j + \sum_ih_i\sigma_i$ where $J$ represents the interactions between spins, $\sigma \in \{+1,-1\}$ denotes the spin state, and $h$ is an external field.It's actually a spin glass model. By using Ising machines, we could find out the ground state of the spin glass model (energy of the system is minimized). 
# It's actually a type of spin glass model. In a spin glass, spins are arranged disorderly with $J$ varying in sign and magnitude. Generally speaking, our goal is to find the spin states that minimize the energy of the system(ground state).

# Imagine that we have an Ising machine, we could first reduce the factoring problem to the spin glass problem and use it to find the ground state of spin glass. Then we 
# extract the solution back to the factoring problem and finally we could crack the RSA encryption system! In the next part, let's use `ProblemReductions.jl` to realize this process.

# ---
# ## Factoring -> Spin Glass
# To start with, we import the necessary packages.
using ProblemReductions, LuxorGraphPlot, LuxorGraphPlot.Luxor
# And then we use the reduction graph to find the reduction path from the factoring problem to the spin glass problem.
g = reduction_graph()
paths = reduction_paths(Factoring, SpinGlass)
# Here, [`reduction_graph`](@ref) returns a directed graph where the nodes are the problem types and the edges are the reduction rules.
# For the original problem and the target problem, we check whether there is a path between their nodes and if so, the [`reduction_paths`](@ref) function will return the path.
# Now let's check the path from the factoring problem to the spin glass problem.
g.nodes[paths[1]]
# Then we get the path: Factoring -> CircuitSAT -> SpinGlass.
# ### reduce the factoring to the circuit Sat problem
# First, let's initialize a [`Factoring`](@ref) instance. For example, we want to verify that the product of 2 prime numbers is 15. 
n, m, input = 3, 2, 15
f = Factoring(n, m, input)
# We now need to reduce the factoring problem to the Circuit Sat problem and the process of reduction worths noticing -- how could we transfer a factoring problem to a circuit sat problem?
# #### Multiplier
# Our goal is to verify that the product of 2 prime numbers is 15 so we need a gadget in circuit that simulate the product sign, then we construct a circuit to simulate the factoring problem.
# That's actually what a multiplier does. It's a circuit that takes two inputs and outputs their product. And basically, half adder and full adder are the basic building blocks of multiplier.
# Half adder and full adder are circuits composed of logical gates. Here's a table describing there relationship and structure.

# |      | Half adder | Full adder | Multiplier |
# | :---  | :--- | :--- | :--- |
# | gadgets|  XOR, AND | XOR, AND, OR | Half adder, Full adder |
# | inputs | 2 bits | 2 bits and 1 carry| two binary numbers |
# | outputs | sum and carry | sum and carry | product |
# Then we could consider how to build a multiplier using half adder and full adder. 
# After figuring out how multiplier works in this reduction process, we could use the [`reduceto`](@ref) function. This function returns a reduction result containing the 
# target problem and some other information in the reduction process.
cs = reduceto(CircuitSAT, f) 
# Now, we get a Circuit Sat problem `cs` and let's checkout how it looks like.

# ### reduce the circuit Sat problem to the Spin Glass problem
# Similarly, use `reduceto` to reduce the circuit sat problem to the spin glass problem.
sg = reduceto(SpinGlass, cs.circuit)
# Finally, we get a spin glass problem `sg` and imagine we could use the ising machine to find the ground state of `sg`, here we may use `findbest` to solve it.
# And then we could extract the solution back to the factoring problem.

# notes: main figure


