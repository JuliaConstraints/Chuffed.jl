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

function Optimizer(; stdin::IO=stdin, stdout::IO=stdout)
    return FZN.Optimizer(Chuffed_jll.run_chuffed; stdin=stdin, stdout=stdout)
end

end # module
