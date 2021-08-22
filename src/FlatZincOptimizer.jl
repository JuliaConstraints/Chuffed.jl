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
