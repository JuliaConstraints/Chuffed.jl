# Copyright (c) 2021 Thibaut Cuvelier and contributors
#
# Use of this source code is governed by an MIT-style license that can be found
# in the LICENSE.md file or at https://opensource.org/licenses/MIT.

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
    return MOIU.CachingOptimizer(
        MOIU.UniversalFallback(MOIU.Model{T}()),
        MOI.Bridges.full_bridge_optimizer(
            MOIU.CachingOptimizer(
                MOIU.UniversalFallback(MOIU.Model{T}()),
                Chuffed.Optimizer(),
            ),
            T,
        ),
    )
end

@testset "Chuffed" begin
    include("chuffed.jl")
    include("MOI.jl")
end
