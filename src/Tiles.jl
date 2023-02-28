module Tiles
    export TileType, Unpassable, Terrain, Swamp, Water
    
    import LinearAlgebra.Symmetric
    @enum TileType Unpassable Terrain Swamp Water

    transition_costs = 
        Symmetric(
                   [ 
                     0 0 0 0;
                     0 1 3 0;
                     0 0 2 0;
                     0 0 0 0;
                  ]
                )
end

