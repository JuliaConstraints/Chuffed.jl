@testset "MOI interface" begin
    @testset "basic.fzn" begin
        model = optimizer(Int)
        
        @test MOI.supports_add_constrained_variable(model, MOI.Integer)
        @test MOI.supports_constraint(CP.FlatZinc.Optimizer(), MOI.ScalarAffineFunction{Int}, MOI.LessThan{Int})
        # @test MOI.supports_constraint(Chuffed.FZN.Optimizer(), MOI.SingleVariable, MOI.GreaterThan{Int})
        # @test MOI.supports_constraint(model, MOI.SingleVariable, MOI.GreaterThan{Int})

        # println(@which MOI.supports_constraint(CP.FlatZinc.Optimizer(), MOI.ScalarAffineFunction{Int}, MOI.LessThan{Int}))
        # println(@which MOI.supports_constraint(Chuffed.FZN.Optimizer(), MOI.SingleVariable, MOI.GreaterThan{Int}))
        # println(@which MOI.supports_constraint(model, MOI.SingleVariable, MOI.GreaterThan{Int}))

        x, x_int = MOI.add_constrained_variable(model, MOI.Integer())
        c1 = MOI.add_constraint(model, -1 * MOI.SingleVariable(x), MOI.LessThan(-1))
        c2 = MOI.add_constraint(model, 1 * MOI.SingleVariable(x), MOI.LessThan(3))

        @test MOI.is_valid(model, x)
        @test MOI.is_valid(model, x_int)
        @test MOI.is_valid(model, c1)
        @test MOI.is_valid(model, c2)

        MOI.optimize!(model)

        @test MOI.get(model, MOI.TerminationStatus()) === MOI.OPTIMAL
        
        @show MOI.get(model, MOI.VariablePrimal(), x)
        # @test MOI.get(model, MOI.VariablePrimal(), "x1")
    end
end
