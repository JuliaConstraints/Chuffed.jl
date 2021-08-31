@testset "MOI interface" begin
    @testset "basic.fzn" begin
        model = optimizer(Int)
        @test MOI.supports_add_constrained_variable(model, MOI.Integer)

        x = MOI.add_constrained_variable(Chuffed.Optimizer(), MOI.Integer())
        @show x
    end
end
