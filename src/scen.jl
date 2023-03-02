include("Tiles.jl")
include("MapIO.jl")
include("Algorithms.jl")

if length(ARGS) > 2
    println("Wrong number of arguments.")
    exit(1)
end

filename = ARGS[1]
mode = length(ARGS) == 2 ? ARGS[2] : "quiet"


println("Loading scenario...")

io = open(filename, "r")

readline(io)

tmp = split(readline(io))
mapfile = joinpath("maps/",tmp[2])

seekstart(io)
readline(io)

println("Loading map...")

text_map :: Matrix{Char} = MapIO.load_map(mapfile)
map :: Matrix{Tiles.TileType} = MapIO.convert_map(text_map)

total_atime = 0.0
total_dtime = 0.0
instances = 0
correct = 0
afaster_correct = 0

println("Precompiling dijkstra...")
precompile(Algorithms.dijkstra,(Matrix{Tiles.TileType}, Tuple{Int,Int}, Tuple{Int,Int}))
println("Precompiling a_star...")
precompile(Algorithms.a_star,(Matrix{Tiles.TileType}, Tuple{Int,Int}, Tuple{Int,Int}))

while !eof(io)

    infos = split(readline(io))

    starty, startx = parse(Int,infos[6]) + 1, parse(Int, infos[5]) + 1
    targety, targetx = parse(Int,infos[8]) + 1, parse(Int, infos[7]) + 1

    start = (starty,startx)
    target = (targety,targetx)

    ymax,xmax = size(map)

    expected = floor(parse(Float64,infos[9]))
    if mode == "verbose"
        println("Launching scenario ", instances, " searching from ", start, " to ", target)
    end
    td = @elapsed dpath = Algorithms.dijkstra(map, start, target)
    
    ta = @elapsed apath = Algorithms.a_star(map, start, target)
    
    global instances += 1

    global total_dtime += td
    global total_atime += ta

    dcost = Tiles.path_cost(map, dpath)
    acost = Tiles.path_cost(map, apath)


    global correct += dcost == acost ? 1 : 0
    global afaster_correct += dcost == acost && td > ta ? 1 : 0
    
    if mode == "verbose"
        println("Dijkstra finished in  : ", td, " seconds, with cost  : ", dcost)
        println("A* finished in  : ", ta, " seconds, with cost : ", acost)
        if dcost == acost
            println("Success.")
        else
            println("Failure.")
        end
        print('\n')
    end

end

println("-------------------------------")

println("Ran ", instances, " scenarios")
println("Both algorithms agreed on ", correct, " of them")
println("Average time for Dijkstra was ", total_dtime / instances, " seconds")
println("Average time for A* was ", total_atime / instances, " seconds")
println("A* was faster in ", afaster_correct, " scenarios where both algorithms agreed")
