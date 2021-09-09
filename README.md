# Chuffed.jl

Chuffed.jl is a wrapper for the [Chuffed](https://github.com/chuffed/chuffed)
constraint-programming solver. Chuffed is free software and Chuffed.jl is a 
free wrapper for Chuffed (both are released under an MIT license).
Chuffed.jl is a community project that is unrelated to Chuffed; in particular, 
it is not maintained by the same group of persons.

Chuffed.jl does not expose a low-level API for Chuffed, as wrapping occurs at 
the FlatZinc level. 

## Installation

Installation is easy, as [Chuffed is available as a JLL](https://github.com/JuliaBinaryWrappers/Chuffed_jll.jl/)
precompiled for most platforms.

```julia
]add Chuffed
```

## Use with JuMP

Chuffed.jl only works through MathOptInterface, for which JuMP is a modelling
layer. Using [JuMP.jl](https://github.com/jump-dev/JuMP.jl) is highly 
recommended.

This can be done using a ``Chuffed.Optimizer`` object. Here is how to create a
*JuMP* model that uses Chuffed as solver.
```julia
using JuMP, Chuffed

model = Model(Chuffed.Optimizer)
```
