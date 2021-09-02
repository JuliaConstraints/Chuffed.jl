module Chuffed

import MathOptInterface
import ConstraintProgrammingExtensions
using Chuffed_jll

const MOI = MathOptInterface
const MOIU = MOI.Utilities
const CleverDicts = MOIU.CleverDicts
const CP = ConstraintProgrammingExtensions

module FZN
include("FlatZincOptimizer.jl")
end

function run_chuffed(args)
    return String(read(`$(Chuffed_jll.fznchuffed()) $(args)`))
end

function Optimizer()
    return FZN.Optimizer(Chuffed_jll.fznchuffed())
end

end # module
