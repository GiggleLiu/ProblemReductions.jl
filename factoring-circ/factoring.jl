using GenericTensorNetworks, ProblemReductions

function test_circuit()
    m = n = 62
    a = BigInt(4611686018427387847)
    b = BigInt(4611686018427387817)
    fact = Factoring(m, n, a * b)
    res = reduceto(CircuitSAT, fact)
    target = target_problem(res)  # NOTE: by default, the circuit 
    problem = CircuitSAT{ProblemReductions.SAT}(target.circuit, target.symbols, target.weights)
    tnet = GenericTensorNetwork(problem; optimizer=nothing)
    tensors = GenericTensorNetworks.generate_tensors(1, tnet.problem)

    @info "Testing circuit"
    @info is_satisfied(problem, rand(Bool, num_variables(problem)))  # random bitstring does not satisfy the circuit
    return tnet, tensors
end

tnet, tensors = test_circuit()