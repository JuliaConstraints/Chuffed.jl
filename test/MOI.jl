@testset "MOI interface" begin
    @testset "basic.fzn" begin
        model = optimizer(Int)
        @show model
        x = MOI.add_constrained_variable(model, MOI.Integer())
    end
end
