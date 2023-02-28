import Base.Ordering
import Base.lt
import DataStructures.eq

struct AStarOrdering <: Ordering end

lt(::AStarOrdering, (g1, h1, t1), (g2, h2, t2)) = g1 + h1 < g2 + h2 || g1 + h1 == g2 + h2 && t1 < t2

function a_star(map :: Matrix{TileType}, 
                start :: Tuple{Int,Int}, 
                target :: Tuple{Int,Int}
               )

    ymax, xmax = size(map)

    #Broadcast is lazy so we must do this
    types = map
    parents = fill((0,0), size(map))
    pathlengths = fill(0, size(map))
    states = fill(Unvisited, size(map))


    current = start


    function heuristic((y1,x1), (y2,x2))
        dx = x2 - x1
        dy = y2 - y1
        return abs(dx) + abs(dy)
    end

    function tie_breaker((y1,x1), (y2,x2))
        dx1 = x2 - x1
        dy1 = y2 - y1
        
        ty,tx = target

        dx2 = tx - x1
        dy2 = ty - y1

        n = sqrt(dx2 ^ 2 + dy2 ^2)
        dx2 /= n
        dy2 /= n
        
        return dx1 * dx2 + dy1 * dy2 
    end
    open_cells = PriorityQueue{Tuple{Int,Int}, Tuple{Int,Float64,Float64}}(AStarOrdering())

    enqueue!(open_cells,start,(0,heuristic(start,target), 0))

    while current != target && length(open_cells) > 0

        current = dequeue!(open_cells)
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

            cost = Tiles.transition_costs[Int(type) + 1, Int(ntype) + 1]

            newlength =  pathlength+cost
            if states[ny,nx] == Unvisited
                enqueue!(open_cells, (ny,nx), (newlength,heuristic((ny,nx), target), tie_breaker((ny,nx),target)))
                states[ny,nx] = Opened
                parents[ny,nx] = current
                pathlengths[ny,nx] = newlength
            elseif states[ny,nx] == Opened && newlength < pathlengths[ny,nx]
                parents[ny,nx] = current
                pathlengths[ny,nx] = newlength
                open_cells[(ny,nx)] =  (newlength,heuristic((ny,nx), target), tie_breaker((ny,nx),target))            
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
