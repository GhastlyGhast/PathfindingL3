include("Tiles.jl")
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


println("Loading scenario...")

io = open(filename, "r")

readline(io)

tmp = split(readline(io))
mapfile = joinpath("maps/",tmp[2])

seekstart(io)
readline(io)

println("Loading map...")

text_map = MapIO.load_map(mapfile)
map = MapIO.convert_map(text_map)

println("Map Loaded.")

total_time = 0.0
instances = 0
correct = 0

while !eof(io)

    infos = split(readline(io))

    starty, startx = parse(Int,infos[6]) + 1, parse(Int, infos[5]) + 1
    targety, targetx = parse(Int,infos[8]) + 1, parse(Int, infos[7]) + 1

    start = (starty,startx)
    target = (targety,targetx)

    ymax,xmax = size(map)

    expected = floor(parse(Float64,infos[9]))

    if haskey(algo_dict, algorithm)
        println("Launching search...")
        t1 = time()
        path = algo_dict[algorithm](map, start, target)
        t2 = time()
        global total_time += t2 - t1
        global instances += 1
        global correct += length(path) - 1 == expected ? 1 : 0
        println("Finished in  : ", t2 - t1, " seconds")
        println("Found path of length : ", length(path) - 1, ", expected : ", expected)
        if length(path) - 1 == expected
            println("Success.")
        else
            println("Failure.")
        end
    else
        error("Not a valid algorithm : " * algorithm)
    end

end

println("-------------------------------")

println("Ran ", instances, " scenarios")
println("Optimal path was correct in ", correct, " of them")
println("Average time was ", total_time / instances, " seconds")
