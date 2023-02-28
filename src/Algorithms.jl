module Algorithms
    export djikstra, a_star
    using ..Tiles
    import DataStructures.PriorityQueue
    import DataStructures.enqueue!
    import DataStructures.dequeue!
    import DataStructures.dequeue_pair!

    @enum TileState Unvisited Opened Closed

    include("dijkstra.jl")
    include("a_star.jl")

end
