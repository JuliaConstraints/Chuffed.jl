# TODO: introduce a way for solvers to indicate that they support some features. For now, only the barest FZN file is generated, with extremely little structure.

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
        stdin::IO,
        stdout::IO,
    )::String

Execute the `solver` given the FlatZinc file at `fzn_filename`, a vector of `options`,
and `stdin` and `stdout`. If anything goes wrong, throw a descriptive error.
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
    stdin::IO,
    stdout::IO,
)
    solver.f() do solver_path
        ret = run(
            pipeline(
                `$(solver_path) $(options) $(fzn_filename)`,
                stdin = stdin,
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

mutable struct Optimizer <: MOI.AbstractOptimizer
    inner::MOI.FileFormats.NL.Model
    solver_command::AbstractFznSolverCommand
    options::Dict{String, Any}
    stdin::Any
    stdout::Any
    results::_FznResults
    solve_time::Float64
end

"""
    _solver_command(x::Union{Function, String})

Functionify the solver command so it can be called as follows:

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
        stdin::Any = stdin,
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
Redirect IO using `stdin` and `stdout`. These arguments are passed to
`Base.pipeline`. [See the Julia documentation for more details](https://docs.julialang.org/en/v1/base/base/#Base.pipeline-Tuple{Base.AbstractCmd}).

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
    stdin_::IO=stdin,
    stdout_::IO=stdout,
)
    return Optimizer(
        CP.FlatZinc.Optimizer(),
        _solver_command(solver_command),
        Dict{String, String}(opt => "" for opt in solver_args),
        stdin_,
        stdout_,
        _NLResults(),
        NaN,
    )
end

Base.show(io::IO, ::Optimizer) = print(io, "A FlatZinc (flattened MiniZinc) model")

MOI.get(model::Optimizer, ::MOI.SolverName) = "FlatZincWriter"

MOI.supports(::Optimizer, ::MOI.Name) = MOI.supports(model.inner, MOI.Name())

MOI.get(model::Optimizer, ::MOI.Name) = MOI.get(model.inner, MOI.Name())

function MOI.set(model::Optimizer, ::MOI.Name, name::String)
    MOI.set(model.inner, MOI.Name(), name)
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
