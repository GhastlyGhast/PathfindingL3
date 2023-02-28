function dijkstra(map :: Matrix{TileType}, 
                  start :: Tuple{Int,Int}, 
                  target :: Tuple{Int,Int}
                 )
    
    ymax, xmax = size(map)
    
    #Broadcast is lazy so we must do this
    types = map
    parents = fill((0,0), size(map))
    pathlengths = fill(0, size(map))
    states = fill(Unvisited, size(map))

    open_cells = PriorityQueue{Tuple{Int,Int}, Int}()

    enqueue!(open_cells,start,0)

    current = start

    while current != target && length(open_cells) > 0

        current,pathlength = dequeue_pair!(open_cells)
        cy, cx = current
        type = types[cy, cx]
        pathlength = pathlengths[cy, cx]

        neighbours = [(cy+1,cx), (cy-1,cx), (cy, cx+1), (cy, cx-1)]

        for (ny,nx) in neighbours
            if nx < 1 || ny < 1 || nx > xmax || ny > ymax 
                continue
            end

            ntype = types[ny,nx]
            if !Tiles.transition_possible[Int(type) + 1, Int(ntype) + 1]
                states[ny,nx] = Closed 
                continue
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
