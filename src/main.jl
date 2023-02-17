
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

algorithm = ARGS[1]
filename = ARGS[2]

map = MapIO.load_map(filename)
println(Algorithms.dijkstra(map, (2,4), (47,45)))
