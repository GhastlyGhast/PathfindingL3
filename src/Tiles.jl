module Tiles
    export TileType, Wall, Terrain, Swamp, Water, path_cost
    
    @enum TileType Wall = 1 Terrain = 2 Swamp = 3 Water = 4

    transition_costs :: Matrix{Int} = 
                   [ 
                     0 0   0   0
                   ; 0 10  100 0 
                   ; 0 100 2   20
                   ; 0 0   10  8  
                   ]

    transition_possible :: Matrix{Bool} = 
                   [ 
                     false false false false;
                     false true  true  false;
                     false true  true  true ;
                     false false true  true ;
                  ]

    function path_cost(map :: Matrix{Tiles.TileType}, path :: Vector{Tuple{Int, Int}})
        cost = 0
        for i in 1:(length(path) - 1)
            y1,x1 = path[i]
            y2,x2 = path[i+1]
            cost += Tiles.transition_costs[Int(map[y1,x1]), Int(map[y2,x2])]
        end
        return cost
    end

end

