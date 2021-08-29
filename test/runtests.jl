using Chuffed
using MathOptInterface
using ConstraintProgrammingExtensions

using Test

const MOI = MathOptInterface
const MOIT = MOI.Test
const MOIB = MOI.Bridges
const CP = ConstraintProgrammingExtensions
const COIT = CP.Test

@testset "Chuffed" begin
    include("parsing.jl")

    # include("api_java.jl")
    # include("MOI.jl")
end
