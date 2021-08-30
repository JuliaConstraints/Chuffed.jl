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
    return Chuffed_jll.fznchuffed() do exe
        String(read(`$(exe) $(args)`))
    end
end

function Optimizer()
    return FZN.Optimizer(run_chuffed)
end

end # module
