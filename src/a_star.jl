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
    grid = (t -> Tile(t,Unvisited,(0,0),0)).(map)

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

            cost = Tiles.transition_costs[Int(type) + 1, Int(ntype) + 1]

            newlength =  pathlength+cost
            if grid[ny,nx].state == Unvisited
                enqueue!(open_cells, (ny,nx), (newlength,heuristic((ny,nx), target), tie_breaker((ny,nx),target)))
                grid[ny,nx].state = Opened
                grid[ny,nx].parent = current
                grid[ny,nx].length = newlength
            elseif grid[ny,nx].state == Opened && newlength < grid[ny,nx].length
                grid[ny,nx].parent = current
                grid[ny,nx].length = newlength
                open_cells[(ny,nx)] =  (newlength,heuristic((ny,nx), target), tie_breaker((ny,nx),target))            
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
