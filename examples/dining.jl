# # Dining with Friends(developing yet)
# ---
# ## Inviting friends to dinner > cracking a bank encryption system
# Using this package, we could showcase the problem how inviting friends to a dinner party is harder than cracking a bank encryption system.Let's introduce some background knowledge.

# ### Intor to RSA 
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

# So basically, RSA relies on factoring and if we could reduce factoring to maxcut problem, we could show that inviting friends to a dinner party is harder than cracking a bank encryption system.  
# Next part, I'll reduce factoring to the maxcut by: Factoring -> Circuit Sat -> SpinGlass -> MaxCut.

# ---
# ## Factoring -> MaxCut
using ProblemReductions, Graphs, LuxorGraphPlot
# For a given number $n$, we could create a factoring problem.
# ### Create a factoring problem
# ### reduce the factoring to the circuit Sat problem

# could I visualize this circuit Sat?
# ### reduce the circuit Sat problem to the SpinGlass problem
# Visualize this SpinGlass problem
# ### reduce the SpinGlass problem to the MaxCut problem
# Visualize this MaxCut problem and explain how the maxcut problem represents inviting friends to a dinner party
