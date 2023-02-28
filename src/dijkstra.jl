function dijkstra(map :: Matrix{TileType}, 
                  start :: Tuple{Int,Int}, 
                  target :: Tuple{Int,Int}
                 )
    
    ymax, xmax = size(map)
    
    #Broadcast is lazy so we must do this
    types = map
    parents = Matrix{Tuple{Int,Int}}(undef, size(map))
    pathlengths = Matrix{Int}(undef, size(map))
    states = Matrix{TileState}(undef, size(map))

    for y in 1:ymax
        for x in 1:xmax
            parents[y,x] = (0,0)
            pathlengths[y,x] = 0
        end
    end



    open_cells = PriorityQueue{Tuple{Int,Int}, Int}()

    enqueue!(open_cells,start,0)

    current = start

    while current != target && length(open_cells) > 0

        current,pathlength = dequeue_pair!(open_cells)
        cy, cx = current
        type = types[cy, cx]
        pathlength = pathlengths[cy, cx]

        function try_open(ny, nx)
            if nx < 1 || ny < 1 || nx > xmax || ny > ymax 
                return
            end

            ntype = types[ny,nx]
            if !Tiles.transition_possible[Int(type) + 1, Int(ntype) + 1]
                states[ny,nx] = Closed 
                return
            end
            newlength =  pathlength+Tiles.transition_costs[Int(type) + 1, Int(ntype) + 1]
            if states[ny,nx] == Unvisited
                enqueue!(open_cells, (ny,nx), newlength)
                states[ny,nx] = Opened
                parents[ny,nx] = current
                pathlengths[ny,nx] = newlength
            elseif states[ny,nx] == Opened && newlength < pathlengths[ny,nx]
                parents[ny,nx] = current
                pathlengths[ny,nx] = newlength
                open_cells[(ny,nx)] = newlength
            end
        end
        
        try_open(cy, cx+1)
        try_open(cy, cx-1)
        try_open(cy+1, cx)
        try_open(cy-1, cx)

        states[cy,cx] = Closed
       
    end

    path = Tuple{Int,Int}[]

    if current != target
        return path
    end
    
    while current != start
        pushfirst!(path,current) 
        cy, cx = current
        current = parents[cy, cx]
    end

    pushfirst!(path,start)

    return path

end
