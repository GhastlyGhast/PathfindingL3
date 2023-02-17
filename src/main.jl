@enum Obstacle Unpassable

struct Passable
    cost :: Real
end

TileType = Union{Obstacle, Passable}

passable_costs = 
         Dict(
               '.' => 1,
               'G' => 1,
               'S' => 3
             )

function parse_tile(c :: Char) :: TileType
    if c == 'T' || c == '@' || c == 'O'
        return Unpassable
    elseif haskey(passable_costs,c)
        return Passable(passable_costs[c])
    else
        error("\"" * c  * "\" does not represent terrain.")
    end
end

function fail_fileformat()
   error("File isn't of the right file format")
end

function read_until_predicate(pipe, p)
    res = ""
    c = read(pipe, Char)
    while !(p(c))
        res = res * c
        c = read(pipe, Char)
    end
    skip(io, -1)
    return res
end 

read_until_whitespace = pipe -> read_until_predicate(pipe, (c -> c == ' ' || c == '\t' || c == '\n' || c == '\r'))

if length(ARGS) != 2
    println("Wrong number of arguments.")
    exit(1)
end

algorithm = ARGS[1]
filename = ARGS[2]

println("Loading map from ", filename)

io = open(filename, "r")

if readline(io) != "type octile"
    fail_fileformat()
end

if read_until_whitespace(io) != "height"
    fail_fileformat()
end

skip(io, 1)

height = parse(Int, read_until_whitespace(io))

skip(io, 1)
if read_until_whitespace(io) != "width"
    fail_fileformat()
end

skip(io, 1)

width = parse(Int, read_until_whitespace(io))

skip(io, 1)

readline(io)

slurp = fill(' ', (height, width))

for i in 1:height
    slurp[i,:] = collect(readline(io))
end

map = convert(Matrix{TileType}, parse_tile.(slurp))
