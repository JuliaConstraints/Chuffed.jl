module Chuffed

import ConstraintProgrammingExtensions
using Chuffed_jll

const CP = ConstraintProgrammingExtensions

function run_chuffed(args)
    return String(read(`$(Chuffed_jll.fznchuffed()) $(args)`))
end

function Optimizer()
    return CP.FlatZinc.Optimizer(Chuffed_jll.fznchuffed())
end

end # module
