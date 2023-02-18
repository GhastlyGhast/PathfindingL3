module MapIO
    export load_map
    using ..Tiles

    passable_types = 
             Dict(
                   '.' => Terrain,
                   'G' => Terrain,
                   'S' => Swamp,
                   'W' => Unpassable,
                   'O' => Unpassable,
                   'T' => Unpassable,
                   '@' => Unpassable
                 )


    function parse_tile(c :: Char) :: TileType
        if haskey(passable_types,c)
            return passable_types[c]
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
        skip(pipe, -1)
        return res
    end 

    read_until_whitespace = pipe -> read_until_predicate(pipe, (c -> c == ' ' || c == '\t' || c == '\n' || c == '\r'))

    function load_map(filename)
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

        map = fill(' ', (height, width))

        for i in 1:height
            map[i,:] = collect(readline(io))
        end

        return map
    end

    function convert_map(map)
        return parse_tile.(map)
    end

end
