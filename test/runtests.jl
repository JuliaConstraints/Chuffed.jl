using Chuffed
using MathOptInterface
using ConstraintProgrammingExtensions

using Test

const MOI = MathOptInterface
const MOIB = MOI.Bridges
const MOIT = MOI.Test
const MOIU = MathOptInterface.Utilities
const CP = ConstraintProgrammingExtensions
const COIT = CP.Test

# Adapted copy of AmplNLWriter's optimizer (in the tests)
# https://github.com/jump-dev/AmplNLWriter.jl/blob/327fa0bd46b48d7b2be9bbc08e728070d89d0943/test/MOI_wrapper.jl
function optimizer(T)
    model = Chuffed.Optimizer()
    return MOIU.CachingOptimizer(
        MOIU.UniversalFallback(MOIU.Model{T}()),
        MOI.Bridges.full_bridge_optimizer(
            MOIU.CachingOptimizer(
                MOIU.UniversalFallback(MOIU.Model{T}()),
                model,
            ),
            T,
        ),
    )
end

@testset "Chuffed" begin
    include("parsing.jl")
    include("MOI.jl")
end
