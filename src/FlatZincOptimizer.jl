# TODO: introduce a way for solvers to indicate that they support some features. For now, only the barest FZN file is generated, with extremely little structure.

import MathOptInterface
import ConstraintProgrammingExtensions

const MOI = MathOptInterface
const CP = ConstraintProgrammingExtensions

# Abstract interface for FZN solvers. 
# Based on AmplNLWriter.jl's AbstractSolverCommand and call_solver.

"""
    AbstractFznSolverCommand

An abstract type that allows overriding the call behaviour of the solver.
See also: [`call_fzn_solver`](@ref).
"""
abstract type AbstractFznSolverCommand end

"""
    call_fzn_solver(
        solver::AbstractFznSolverCommand,
        fzn_filename::String,
        options::Vector{String},
        stdout::IO, # TODO: to keep?
    )::String

Execute the `solver` given the FlatZinc file at `fzn_filename`, a vector of `options`,
and `stdout`. If anything goes wrong, throw a descriptive error.
This function should not return anything.

As is customary with FlatZinc solvers, the solution is output on `stdout`.
"""
function call_fzn_solver end

# A basic solver that respects MiniZinc's CLI.
# Based on AmplNLWriter.jl's _DefaultSolverCommand.

struct DefaultFznSolverCommand{F} <: AbstractFznSolverCommand
    f::F
end

function call_fzn_solver(
    solver::DefaultFznSolverCommand,
    fzn_filename::String,
    options::Vector{String},
    stdout::IO,
)
    solver.f() do solver_path
        ret = run(
            pipeline(
                `$(solver_path) $(options) $(fzn_filename)`,
                stdout = stdout,
            ),
        )
        if ret.exitcode != 0
            error("Nonzero exit code: $(ret.exitcode)")
        end
    end
    return
end

# MOI wrapper.
# Based on AmplNLWriter.jl's _NLResults and Optimizer. _solver_command is 
# copy-pasted.
# The main difference is that typical solutions do not have a Float64 type,
# but rather Int. However, it all depends on the actual FZN solver that is
# used below (some of them can still deal with floats).

struct _FznResults
    raw_status_string::String
    termination_status::MOI.TerminationStatusCode
    primal_status::MOI.ResultStatusCode
    objective_value::Real
    primal_solution::Dict{MOI.VariableIndex, Real}
end

function _FznResults()
    return _FznResults(
        "Optimize not called.",
        MOI.OPTIMIZE_NOT_CALLED,
        MOI.NO_SOLUTION,
        NaN,
        Dict{MOI.VariableIndex, Float64}(),
    )
end

function _parse_fzn_value(str::AbstractString)
    # Heuristically guess the type of the output value: either integer or 
    # float.
    if '.' in str
        return parse(Float64, str)
    else
        return parse(Int, str)
    end
end

"""
    _parse_to_assignments(str::String)::Vector{Dict{String, Vector{Number}}}

Parses the output of a FlatZinc-compatible solver into a list of dictionaries
mapping the name of the variables to their values (either a scalar or a vector
of numbers). The values are automatically transformed into the closest type
(integer or float).
"""
function _parse_to_assignments(str::String)::Vector{Dict{String, Vector{Number}}}
    results = Dict{String, Vector{Number}}[]

    # There may be several results returned by the solver. Each solution is 
    # separated from the others by `'-' ^ 10`.
    str_split = split(str, '-' ^ 10)[1:(end - 1)]
    n_results = length(str_split)
    sizehint!(results, n_results)

    for i in 1:n_results
        push!(results, Dict{String, Vector{Number}}())

        # Each value is indicated in its own statement, separated by a 
        # semi-colon.
        for part in split(strip(str_split[i]), ';')
            if isempty(part)
                continue
            end

            var, val = split(part, '=')
            var = strip(var)
            val = strip(val)

            # Either an array or a scalar. Always return an array for 
            # simplicity. A scalar is simply an array with one element.
            if !occursin("array", val)
                # Scalar. Just a value: "1", "1.0".
                results[i][var] = [_parse_fzn_value(val)]
            else
                # Array. Several arguments: "array1d(1..2, [1, 2])", 
                # "array2d(1..2, 1..2, [1, 2, 3, 4])". 
                # TODO: should dimensions be preserved? (First argument[s] of arrayNd.)
                val = split(split(val, '[')[2], ']')[1]
                results[i][var] = map(_parse_fzn_value, map(strip, split(val, ',')))
            end
        end
    end

    return results
end

mutable struct Optimizer <: MOI.AbstractOptimizer
    inner::CP.FlatZinc.Optimizer
    solver_command::AbstractFznSolverCommand
    options::Dict{String, Any}
    stdout::Any
    results::_FznResults
    solve_time::Float64
end

"""
    _solver_command(x::Union{Function, String})

Functionify the solver command as an [`AbstractFznSolverCommand`](@ref) object,
so it can be called as follows:

```julia
foo = _solver_command(x)
foo() do path
    run(`\$(path) args...`)
end
```
"""
_solver_command(x::String) = DefaultFznSolverCommand(f -> f(x))
_solver_command(x::Function) = DefaultFznSolverCommand(x)
_solver_command(x::AbstractFznSolverCommand) = x

"""
    Optimizer(
        solver_command::Union{String, Function},
        solver_args::Vector{String};
        stdout:Any = stdout,
    )

Create a new FlatZinc-backed Optimizer object.

`solver_command` should be one of two things:

* A `String` of the full path of a FlatZinc-compatible executable
* A function that takes takes a function as input, initialises any environment
  as needed, calls the input function with a path to the initialised 
  executable, and then destructs the environment.

`solver_args` is a vector of `String` arguments passed solver executable.
However, prefer passing `key=value` options via `MOI.RawParameter`.
Redirect IO using `stdout`. These arguments are passed to `Base.pipeline`. 
[See the Julia documentation for more details](https://docs.julialang.org/en/v1/base/base/#Base.pipeline-Tuple{Base.AbstractCmd}).

## Examples

A string to an executable:

```julia
Optimizer("/path/to/fzn.exe")
```

A custom function:

```julia
function solver_command(f::Function)
    # Create environment...
    ret = f("/path/to/fzn")
    # Destruct environment...
    return ret
end
Optimizer(solver_command)
```
"""
function Optimizer(
    solver_command::Union{AbstractFznSolverCommand, String, Function}="",
    solver_args::Vector{String}=String[];
    stdout::IO=stdout,
)
    return Optimizer(
        CP.FlatZinc.Optimizer(),
        _solver_command(solver_command),
        Dict{String, String}(opt => "" for opt in solver_args),
        stdout,
        _NLResults(),
        NaN,
    )
end

Base.show(io::IO, ::Optimizer) = print(io, "A FlatZinc (flattened MiniZinc) model")

MOI.get(model::Optimizer, ::MOI.SolverName) = "FlatZincWriter"

function MOI.supports(model::Optimizer, attr::MOI.AnyAttribute, x...) 
    return MOI.supports(model.inner, attr, x...)::Bool
end

function MOI.get(model::Optimizer, attr::MOI.AnyAttribute, x...) 
    return MOI.get(model.inner, attr, x...)
end

function MOI.set(model::Optimizer, attr::MOI.AnyAttribute, x...) 
    MOI.set(model.inner, attr, x...)
    return
end

function MOI.empty!(model::Optimizer)
    MOI.empty!(model.inner)
    # Only two attributes to empty, the other ones link the actual solver.
    model.results = _NLResults()
    model.solve_time = NaN
    return
end

MOI.is_empty(model::Optimizer) = MOI.is_empty(model.inner)

# Specific case of dual solution: getting it must be supported, but few CP
# solvers have it accessible (none?).
# https://github.com/jump-dev/MathOptInterface.jl/pull/1561#pullrequestreview-740032701

MOI.supports(::Optimizer, ::MOI.DualStatus) = true
MOI.get(::Optimizer, ::MOI.DualStatus) = MOI.NO_SOLUTION
