# # Use Ising machines to crack RSA encryption system
# ---
# ## 
# Using this package, we could reduce the factoring problem to the spin glass problem and thereby use Ising machines to help crack RSA encryption systems.

# ### Intro to RSA 
# RSA is a public-key cryptosystem. It's widely used in encryption algorithm that helps secure bank transactions and communications. 
# Here's the Introduction->[RSA encryption](https://en.wikipedia.org/wiki/RSA_(cryptosystem)). Easily explained, there are public key $(n,e)$ and private key$(n,d)$. 
# The attacker needs to factorize the $n$, a product of two large prime numbers. So the security of RSA comes from factoring problem.
# ### Factoring problem
# The factoring problem is to find the prime factors of a composite number. It's a pratically hard problem. Generally, the input size in RSA is 2048 bits.
# Consider two algorithms to solve it: General number field sieve(GNFS, a good algorithm in factoring) and  Brute force. 

# | Algorithm | Time complexity | Operations | Time ($10^{12}$ ops/s)  |
# | :--- | :--- | :--- | :--- | 
# | GNFS | $O(e^{(\log n)^{1/3}(\log \log n)^{2/3}})$ | $2^{112}$ | $≈ 7 \times 10^{20}$ years |
# | Brute force | $O(\sqrt{n})$ | $2^{1024}$|$≈5.7 \times 10^{228}$ years |
# Both are way longer than the age of our universe.

# So basically, RSA relies on factoring and if we could reduce factoring to spin glass problem, we could then use Ising machines to help crack RSA encryption systems.
# Next part, I'll reduce factoring to the spin glass by: Factoring -> Circuit Sat -> Spin Glass. 

# ---
# ## Factoring -> Spin Glass
# To start with, we import the necessary packages.
using ProblemReductions, Graphs
# ### reduce the factoring to the circuit Sat problem
# First, let's initialize a factoring problem. For example, we want to verify that the product of 2 prime numbers is 15. 
# ```
# n, m, input = 3, 2, 15
# f = Factoring(n, m, input)
# ```
# We now need to reduce the factoring problem to the Circuit Sat problem and the process of reduction worths noticing -- how could we transfer a factoring problem to a circuit sat problem?
# Our goal is to verify that the product of 2 prime numbers is 15 so we need a gadget in circuit that simulate the product sign and 
# Then we could reduce the factoring problem to the Circuit Sat problem using `reduceto` function.
# ````
# cs = reduceto(CircuitSAT, f) # not yet implemented since Factoring has not been merged yet
# ```
# (Explain multiplier here,included half adder and full adder and how to use multiplier to reduce factoring to circuit Sat)

# Circuit Sat, easily explained, is a circuit with some inputs and outputs and the circuit contains some logical constraints like $\land$ and $\lor$. The goal is to find the inputs that make the output true.
# So here we wants to verify that the product of 2 prime numbers is 15. Then we could set the constraints to the outcome to ensure it's 15.

# ### reduce the circuit Sat problem to the Spin Glass problem
# Visualize this Spin Glass problem.
# Introduce Ising and how to use Ising to solve the Spin Glass problem.

