# Copyright (c) 2021 Thibaut Cuvelier and contributors
#
# Use of this source code is governed by an MIT-style license that can be found
# in the LICENSE.md file or at https://opensource.org/licenses/MIT.

normalize(x) = replace(x, "\r\n" => "\n")

# TODO: move the samples to CP?? Not all solvers will understand all FZN files :/.
@testset "Sanity check for Chuffed" begin
    @testset "basic.fzn" begin
        out_string = Chuffed.run_chuffed(@__DIR__() * "/assets/basic.fzn")
        @test normalize(out_string) == "x = 3;\n\n----------\n"
    end

    @testset "one_solution.fzn" begin
        out_string = Chuffed.run_chuffed(@__DIR__() * "/assets/one_solution.fzn")
        expected = "x = 10;\n\n----------\n==========\n"
        unk = "% [<UNKNOWN>]\n"
        @test normalize(out_string) == expected || normalize(out_string) == expected * unk
    end

    @testset "several_solutions.fzn" begin
        out_string = Chuffed.run_chuffed(["-a", @__DIR__() * "/assets/several_solutions.fzn"])
        @test normalize(out_string) == "xs = array1d(1..2, [2, 3]);\n\n----------\nxs = array1d(1..2, [1, 3]);\n\n----------\nxs = array1d(1..2, [1, 2]);\n\n----------\n==========\n"
    end

    @testset "puzzle.fzn" begin
        out_string = Chuffed.run_chuffed(@__DIR__() * "/assets/puzzle.fzn")
        @test normalize(out_string) == "x = array2d(1..4, 1..4, [5, 1, 8, 8, 9, 3, 8, 6, 9, 7, 7, 8, 1, 7, 8, 9]);\n\n----------\n"
    end

    @testset "einstein.fzn" begin
        out_string = Chuffed.run_chuffed(@__DIR__() * "/assets/einstein.fzn")
        @test normalize(out_string) == "a = array1d(1..5, [5, 4, 3, 1, 2]);\nc = array1d(1..5, [3, 4, 5, 1, 2]);\nd = array1d(1..5, [2, 4, 3, 5, 1]);\nk = array1d(1..5, [3, 1, 2, 5, 4]);\ns = array1d(1..5, [3, 5, 2, 1, 4]);\n\n----------\n"
    end
end

