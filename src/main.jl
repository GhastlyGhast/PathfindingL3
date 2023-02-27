
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

if length(ARGS) != 6
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
starty, startx = parse(Int,ARGS[3]), parse(Int, ARGS[4])
targety, targetx = parse(Int,ARGS[5]), parse(Int, ARGS[6])

start = (starty,startx)
target = (targety,targetx)


println("Loading map...")

text_map = MapIO.load_map(filename)
map = MapIO.convert_map(text_map)

println("Map Loaded.")


ymax,xmax = size(map)


txt_colors = 
    Dict(
        'X' => :cyan,
        '+' => :green,
        '-' => :red,
        '@' => :white,
        'O' => :white,
        '.' => :black,
        'G' => :black,
        'S' => :orange,
        'W' => :blue,
        'T' => :yellow
        )


if haskey(algo_dict, algorithm)
    println("Launching search using " * algorithm)
    path = algo_dict[algorithm](map, start, target)
    println("Result : ", path)
    for (y,x) in path
        text_map[y,x] = 'X'
    end
    text_map[starty,startx] = '+'
    text_map[targety,targetx] = '-'
    for y in 1:ymax
        for x in 1:xmax
            c = text_map[y,x]
            printstyled(stdout, c, color = txt_colors[c])
        end
        print('\n')
    end
else
    error("Not a valid algorithm : " * algorithm)
end
