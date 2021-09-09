# TODO: move the samples to CP?? Not all solvers will understand all FZN files :/.
@testset "Sanity check for Chuffed" begin
    @testset "basic.fzn" begin
        out_string = Chuffed.run_chuffed(@__DIR__() * "/assets/basic.fzn")
        @test out_string == "x = 3;\r\n\r\n----------\r\n"
    end

    @testset "one_solution.fzn" begin
        out_string = Chuffed.run_chuffed(@__DIR__() * "/assets/one_solution.fzn")
        @test out_string == "x = 10;\r\n\r\n----------\r\n==========\r\n"
    end

    @testset "several_solutions.fzn" begin
        out_string = Chuffed.run_chuffed(["-a", @__DIR__() * "/assets/several_solutions.fzn"])
        @test out_string == "xs = array1d(1..2, [2, 3]);\r\n\r\n----------\r\nxs = array1d(1..2, [1, 3]);\r\n\r\n----------\r\nxs = array1d(1..2, [1, 2]);\r\n\r\n----------\r\n==========\r\n"
    end

    @testset "puzzle.fzn" begin
        out_string = Chuffed.run_chuffed(@__DIR__() * "/assets/puzzle.fzn")
        @test out_string == "x = array2d(1..4, 1..4, [5, 1, 8, 8, 9, 3, 8, 6, 9, 7, 7, 8, 1, 7, 8, 9]);\r\n\r\n----------\r\n"
    end

    @testset "einstein.fzn" begin
        out_string = Chuffed.run_chuffed(@__DIR__() * "/assets/einstein.fzn")
        @test out_string == "a = array1d(1..5, [5, 4, 3, 1, 2]);\r\nc = array1d(1..5, [3, 4, 5, 1, 2]);\r\nd = array1d(1..5, [2, 4, 3, 5, 1]);\r\nk = array1d(1..5, [3, 1, 2, 5, 4]);\r\ns = array1d(1..5, [3, 5, 2, 1, 4]);\r\n\r\n----------\r\n"
    end
end

