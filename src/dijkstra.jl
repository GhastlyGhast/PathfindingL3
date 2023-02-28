function dijkstra(map :: Matrix{TileType}, 
                  start :: Tuple{Int,Int}, 
                  target :: Tuple{Int,Int}
                 )
    
    ymax, xmax = size(map)
    grid = (t -> Tile(t,Unvisited,(0,0),0)).(map)

    open_cells = PriorityQueue{Tuple{Int,Int}, Int}()

    enqueue!(open_cells,start,0)

    current = start

    while current != target && length(open_cells) > 0

        current,pathlength = dequeue_pair!(open_cells)
        cy, cx = current
        type = grid[cy, cx].type
        pathlength = grid[cy, cx].length

        function try_open(ny, nx)
            if nx < 1 || ny < 1 || nx > xmax || ny > ymax 
                return
            end

            ntype = grid[ny,nx].type
            if !Tiles.transition_possible[Int(type) + 1, Int(ntype) + 1]
                grid[ny,nx].state = Closed 
                return
            end
            newlength =  pathlength+Tiles.transition_costs[Int(type) + 1, Int(ntype) + 1]
            if grid[ny,nx].state == Unvisited
                enqueue!(open_cells, (ny,nx), newlength)
                grid[ny,nx].state = Opened
                grid[ny,nx].parent = current
                grid[ny,nx].length = newlength
            elseif grid[ny,nx].state == Opened && newlength < grid[ny,nx].length
                grid[ny,nx].parent = current
                grid[ny,nx].length = newlength
                open_cells[(ny,nx)] = newlength
            end
        end
        
        try_open(cy, cx+1)
        try_open(cy, cx-1)
        try_open(cy+1, cx)
        try_open(cy-1, cx)

        grid[cy,cx].state = Closed
       
    end

    path = Tuple{Int,Int}[]

    if current != target
        return path
    end
    
    while current != start
        pushfirst!(path,current) 
        cy, cx = current
        current = grid[cy, cx].parent
    end

    pushfirst!(path,start)

    return path

end
