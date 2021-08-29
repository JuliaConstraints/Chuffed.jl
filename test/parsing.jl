@testset "Parsing FlatZinc output format" begin
    @testset "basic.fzn" begin
        in_file_name = @__DIR__() * "/assets/basic.fzn"
        out_string = Chuffed.run_chuffed(in_file_name)
        @show out_string
        @show Chuffed.FZN._parse_to_fznresults(out_string)
    end

    # @testset "puzzle.fzn" begin
    #     in_file_name = @__DIR__() * "/assets/puzzle.fzn"
    #     out_string = Chuffed.run_chuffed(in_file_name)
    #     @show out_string
    #     @show Chuffed.FZN._parse_to_fznresults(out_string)
    # end
end