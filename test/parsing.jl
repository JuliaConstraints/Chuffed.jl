@testset "Sanity check for Chuffed" begin
    @testset "basic.fzn" begin
        out_string = Chuffed.run_chuffed(@__DIR__() * "/assets/basic.fzn")
        @test out_string == "x = 3;\r\n\r\n----------\r\n"
    end
end

# TODO: move to CP.
@testset "Parsing FlatZinc output format" begin
    @testset "basic.fzn" begin
        out_string = "x = 3;\r\n\r\n----------\r\n"
        @test Chuffed.FZN._parse_to_assignments(out_string) == [Dict("x" => 3)]
    end

    # @testset "puzzle.fzn" begin
    #     in_file_name = @__DIR__() * "/assets/puzzle.fzn"
    #     out_string = Chuffed.run_chuffed(in_file_name)
    #     @show out_string
    #     @show Chuffed.FZN._parse_to_fznresults(out_string)
    # end
end
