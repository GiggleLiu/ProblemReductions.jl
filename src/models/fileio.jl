"""
    writejson(filename::AbstractString, problem::AbstractProblem)

Write a problem to a JSON file.

# Arguments
- `filename::AbstractString`: The name of the file to write to.
- `problem::AbstractProblem`: The problem to write to the file.
"""
function writejson end

for MODEL in [:BicliqueCover, :CircuitSAT, :Circuit, :SpinGlass, :IndependentSet, :MaxCut, :Factoring, :QUBO, :Satisfiability, :SetCovering, :DominatingSet, :SetPacking, :VertexCovering, :MaximalIS, :PaintShop, :Matching, :BinaryMatrixFactorization]
    @eval begin
        function writejson(filename::AbstractString, problem::$MODEL)
            js = JSON.parse(JSON.json(problem))
            js["type"] = "$(typeof(problem).name.name)"
            open(filename, "w") do f
                JSON.print(f, js)
            end
        end
    end
end

function writejson(filename::AbstractString, problem::Coloring)
    js = JSON.parse(JSON.json(problem))
    js["type"] = "$(typeof(problem).name.name)"
    js["k"] = num_flavors(problem)
    open(filename, "w") do f
        JSON.print(f, js)
    end
end

function writejson(filename::AbstractString, problem::KSatisfiability)
    js = JSON.parse(JSON.json(problem))
    js["type"] = "$(typeof(problem).name.name)"
    js["k"] = get_k(typeof(problem))
    open(filename, "w") do f
        JSON.print(f, js)
    end
end

function JSON.show_json(io::JSON.Writer.SC, s::JSON.Writer.CS, x::BooleanExpr)
    if is_var(x)
        return JSON.show_json(io, s, Dict("head" => "var", "var" => x.var))
    else
        return JSON.show_json(io, s, Dict("head" => x.head, "args" => x.args))
    end
end

"""
    readjson(filename::AbstractString)

Read a problem from a JSON file.

# Arguments
- `filename::AbstractString`: The name of the file to read from.
"""
function readjson(filename::AbstractString)
    js = JSON.parsefile(filename)
    problem_type = js["type"]
    
    if problem_type == "SpinGlass"
        return SpinGlass(_render_graph(js["graph"]), js["J"], js["h"])
    elseif problem_type == "IndependentSet"
        graph = _render_graph(js["graph"])
        weights = js["weights"]
        return IndependentSet(graph, weights)
    elseif problem_type == "MaxCut"
        graph = _render_graph(js["graph"])
        weights = js["weights"]
        return MaxCut(graph, weights)
    elseif problem_type == "Factoring"
        return Factoring(js["m"], js["n"], js["input"])
    elseif problem_type == "QUBO"
        matrix = hcat(js["matrix"]...)
        return QUBO(matrix)
    elseif problem_type == "Satisfiability"
        symbols = js["symbols"]
        weights = js["weights"]
        cnf_data = js["cnf"]
        # Deserialize CNF from JSON
        cnf_clauses = CNFClause{Symbol}[]
        for clause_data in cnf_data["clauses"]
            clause_vars = BoolVar{Symbol}[]
            for var_data in clause_data["vars"]
                bvar = BoolVar(Symbol(var_data["name"]), var_data["neg"])
                push!(clause_vars, bvar)
            end
            push!(cnf_clauses, CNFClause(clause_vars))
        end
        cnf = CNF(cnf_clauses)
        return Satisfiability(cnf, weights)
    elseif problem_type == "SetCovering"
        sets = js["sets"]
        weights = js["weights"]
        return SetCovering(Vector{Int}.(sets), weights)
    elseif problem_type == "DominatingSet"
        graph = _render_graph(js["graph"])
        weights = js["weights"]
        return DominatingSet(graph, weights)
    elseif problem_type == "SetPacking"
        sets = js["sets"]
        weights = js["weights"]
        return SetPacking(Vector{Int}.(sets), weights)
    elseif problem_type == "VertexCovering"
        graph = _render_graph(js["graph"])
        weights = js["weights"]
        return VertexCovering(graph, weights)
    elseif problem_type == "MaximalIS"
        graph = _render_graph(js["graph"])
        weights = js["weights"]
        return MaximalIS(graph, weights)
    elseif problem_type == "PaintShop"
        sequence = js["sequence"]
        return PaintShop(sequence)
    elseif problem_type == "Matching"
        graph = _render_graph(js["graph"])
        weights = js["weights"]
        return Matching(graph, weights)
    elseif problem_type == "BinaryMatrixFactorization"
        A = BitMatrix(hcat(js["A"]...))
        k = js["k"]
        return BinaryMatrixFactorization(A, k)
    elseif problem_type == "BicliqueCover"
        graph = _render_graph(js["graph"])
        part1 = Vector{Int}(js["part1"])
        k = js["k"]
        return BicliqueCover(graph, part1, k)
    elseif startswith(problem_type, "Coloring")
        # Handle parametric type Coloring{K}
        graph = _render_graph(js["graph"])
        weights = js["weights"]
        k = js["k"]  # Extract the K parameter
        # Create Coloring{K} with the extracted K parameter
        # Use dynamic construction instead of eval
        return Coloring{k}(graph, weights)
    elseif startswith(problem_type, "KSatisfiability")
        # Handle parametric type KSatisfiability{K}
        symbols = js["symbols"]
        weights = js["weights"]
        cnf_data = js["cnf"]
        k = js["k"]  # Extract the K parameter
        allow_less = js["allow_less"]
        # Deserialize CNF from JSON
        cnf_clauses = CNFClause{Symbol}[]
        for clause_data in cnf_data["clauses"]
            clause_vars = BoolVar{Symbol}[]
            for var_data in clause_data["vars"]
                bvar = BoolVar(Symbol(var_data["name"]), var_data["neg"])
                push!(clause_vars, bvar)
            end
            push!(cnf_clauses, CNFClause(clause_vars))
        end
        cnf = CNF(cnf_clauses)
        # Create KSatisfiability{K} with the extracted K parameter
        # Use dynamic construction instead of eval
        return KSatisfiability{k}(cnf, weights; allow_less=allow_less)
    elseif problem_type == "CircuitSAT"
        circuit_data = js["circuit"]
        symbols = js["symbols"]
        weights = js["weights"]
        # Deserialize Circuit from JSON
        assignments = []
        for assign_data in circuit_data["exprs"]
            outputs = Symbol.(assign_data["outputs"])
            expr = deserialize_boolean_expr(assign_data["expr"])
            push!(assignments, Assignment(outputs, expr))
        end
        circuit = Circuit(assignments)
        return CircuitSAT(circuit)
    elseif problem_type == "Circuit"
        circuit_data = js["exprs"]
        assignments = []
        for assign_data in circuit_data
            outputs = Symbol.(assign_data["outputs"])
            expr = deserialize_boolean_expr(assign_data["expr"])
            push!(assignments, Assignment(outputs, expr))
        end
        return Circuit(assignments)
    else
        throw(ArgumentError("Unsupported problem type: $problem_type"))
    end
end

function _render_graph(graph_data)
    return Graphs.SimpleGraph(graph_data["ne"], Vector{Int}.(graph_data["fadjlist"]))
end

# Helper function to deserialize BooleanExpr
function deserialize_boolean_expr(expr_data)
    if expr_data["head"] == "var"
        return BooleanExpr(Symbol(expr_data["var"]))
    else
        head = Symbol(expr_data["head"])
        args = [deserialize_boolean_expr(arg) for arg in expr_data["args"]]
        return BooleanExpr(head, args)
    end
end