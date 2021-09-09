@testset "MOI interface" begin
    @testset "basic.fzn" begin
        model = optimizer(Int)
        
        @test MOI.supports_add_constrained_variable(model, MOI.Integer)
        @test MOI.supports_constraint(CP.FlatZinc.Optimizer(), MOI.ScalarAffineFunction{Int}, MOI.LessThan{Int})

        # x ∈ {1, 2, 3}
        x, x_int = MOI.add_constrained_variable(model, MOI.Integer())
        c1 = MOI.add_constraint(model, -1 * MOI.SingleVariable(x), MOI.LessThan(-1))
        c2 = MOI.add_constraint(model, 1 * MOI.SingleVariable(x), MOI.LessThan(3))

        @test MOI.is_valid(model, x)
        @test MOI.is_valid(model, x_int)
        @test MOI.is_valid(model, c1)
        @test MOI.is_valid(model, c2)

        MOI.optimize!(model)

        @test MOI.get(model, MOI.TerminationStatus()) === MOI.OPTIMAL
        @test MOI.get(model, MOI.ResultCount()) ≥ 1
        @test MOI.get(model, MOI.VariablePrimal(), x) ∈ Set([1, 2, 3])
        @test MOI.get(model, MOI.VariablePrimal(1), x) ∈ Set([1, 2, 3])
    end

    @testset "Infeasible" begin
        model = optimizer(Int)
        
        @test MOI.supports_add_constrained_variable(model, MOI.Integer)
        @test MOI.supports_constraint(CP.FlatZinc.Optimizer(), MOI.ScalarAffineFunction{Int}, MOI.LessThan{Int})

        # x ∈ ∅
        x, x_int = MOI.add_constrained_variable(model, MOI.Integer())
        c1 = MOI.add_constraint(model, -1 * MOI.SingleVariable(x), MOI.LessThan(-5))
        c2 = MOI.add_constraint(model, 1 * MOI.SingleVariable(x), MOI.LessThan(3))

        @test MOI.is_valid(model, x)
        @test MOI.is_valid(model, x_int)
        @test MOI.is_valid(model, c1)
        @test MOI.is_valid(model, c2)

        MOI.optimize!(model)

        @test MOI.get(model, MOI.TerminationStatus()) === MOI.INFEASIBLE
        @test MOI.get(model, MOI.ResultCount()) == 0
        # TODO: https://github.com/jump-dev/MathOptInterface.jl/issues/1600
        # @test MOI.get(model, MOI.VariablePrimal(), x) ∈ Set([1, 2, 3])
        # @test MOI.get(model, MOI.VariablePrimal(1), x) ∈ Set([1, 2, 3])
    end
end
