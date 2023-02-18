
module Tiles
    export TileType, Unpassable, Terrain, Swamp, Water
    
    import LinearAlgebra.Symmetric
    @enum TileType Unpassable Terrain Swamp Water

    transition_costs = 
        Symmetric(
                   [ 0 0 0 0;
                     0 1 3 0;
                     0 0 2 0;
                     0 0 0 0;
                  ]
                )
end

include("MapIO.jl")
include("Algorithms.jl")

if length(ARGS) != 2
    println("Wrong number of arguments.")
    exit(1)
end

algo_dict =
    Dict(
        "dijkstra" => Algorithms.dijkstra,
        "a_star" => Algorithms.a_star
        )

algorithm = ARGS[1]
filename = ARGS[2]

println("Loading map...")

map = MapIO.load_map(filename)

println("Map Loaded.")

if haskey(algo_dict, algorithm)
    println("Launching search using " * algorithm)
    path = algo_dict[algorithm](map, (2,4), (47,45))
    println("Result : ", path)
else
    error("Not a valid algorithm : " * algorithm)
end
