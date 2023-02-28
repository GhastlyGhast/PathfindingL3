module Tiles
    export TileType, Wall, Terrain, Swamp, Water
    
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
end

