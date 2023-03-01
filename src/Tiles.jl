module Tiles
    export TileType, Wall, Terrain, Swamp, Water, path_cost
    
    import LinearAlgebra.Symmetric
    @enum TileType Wall Terrain Swamp Water

    transition_costs :: Matrix{Int} = 
                   [ 
                     0 0 0 0;
                     0 1 3 0;
                     0 3 2 0;
                     0 0 0 0;
                  ]
    transition_possible :: Matrix{Bool} = 
                   [ 
                     false false false false;
                     false true  true  false;
                     false true  true  false;
                     false false false false;
                  ]

    function path_cost(map :: Matrix{Tiles.TileType}, path :: Vector{Tuple{Int, Int}})
        cost = 0
        for i in 1:(length(path) - 1)
            y1,x1 = path[i]
            y2,x2 = path[i+1]
            cost += Tiles.transition_costs[1 + Int(map[y1,x1]), 1 + Int(map[y2,x2])]
        end
        return cost
    end

end

