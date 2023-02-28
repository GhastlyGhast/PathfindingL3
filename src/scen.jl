include("Tiles.jl")
include("MapIO.jl")
include("Algorithms.jl")

if length(ARGS) != 1
    println("Wrong number of arguments.")
    exit(1)
end

filename = ARGS[1]


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

total_atime = 0.0
total_dtime = 0.0
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

    println("Launching search...")
    td1 = time()
    dpath = Algorithms.dijkstra(map, start, target)
    td2 = time()
    
    ta1 = time()
    apath = Algorithms.a_star(map, start, target)
    ta2 = time()
    
    global instances += 1

    global total_dtime += td2 - td1
    global total_atime += ta2 - ta1
    global correct += length(dpath) == length(apath) ? 1 : 0
    println("Dijkstra finished in  : ", td2 - td1, " seconds, with length : ", length(dpath) -1)
    println("A* finished in  : ", ta2 - ta1, " seconds, with length : ", length(apath) - 1)
    if length(dpath) == length(apath)
        println("Success.")
    else
        println("Failure.")
    end
    print('\n')

end

println("-------------------------------")

println("Ran ", instances, " scenarios")
println("Both algorithms agreed on ", correct, " of them")
println("Average time for Dijkstra was ", total_dtime / instances, " seconds")
println("Average time for A* was ", total_atime / instances, " seconds")
