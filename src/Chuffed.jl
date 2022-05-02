# Copyright (c) 2021 Thibaut Cuvelier and contributors
#
# Use of this source code is governed by an MIT-style license that can be found
# in the LICENSE.md file or at https://opensource.org/licenses/MIT.

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
