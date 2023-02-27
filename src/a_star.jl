import Base.Ordering
import Base.lt
import DataStructures.eq

struct AStarOrdering <: Ordering end

lt(::AStarOrdering, (g1, h1), (g2, h2)) = g1 + h1 < g2 + h2 || g1 + h1 == g2 + h2 && h1 > h2

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

    open_cells = PriorityQueue{Tuple{Int,Int}, Tuple{Int,Float64}}(AStarOrdering())

    enqueue!(open_cells,start,(0,heuristic(start,target)))

    while current != target && length(open_cells) > 0

        current = dequeue!(open_cells)
        cy, cx = current
        type = grid[cy, cx].type
        pathlength = grid[cy, cx].length

        function try_open(ny, nx)
            if nx >= 1 && ny >= 1 && nx <= xmax && ny <= ymax && grid[ny,nx].type != Unpassable
                cost = Tiles.transition_costs[Int(type) + 1, Int(grid[ny,nx].type) + 1]
                if (cx + cy) % 2 == 0
                    if ny != cy 
                        cost = cost + 1
                    end
                elseif nx != cx 
                    cost = cost + 1
                end

                newlength =  pathlength+cost
                if grid[ny,nx].state == Unvisited
                    enqueue!(open_cells, (ny,nx), (newlength,heuristic((ny,nx), target)))
                    grid[ny,nx].state = Opened
                    grid[ny,nx].parent = current
                    grid[ny,nx].length = newlength
                elseif grid[ny,nx].state == Opened && newlength < grid[ny,nx].length
                    grid[ny,nx].parent = current
                    grid[ny,nx].length = newlength
                    open_cells[(ny,nx)] =  (newlength, heuristic((ny,nx), target))
                end
            end
        end
        
        try_open(cy, cx+1)
        try_open(cy, cx-1)
        try_open(cy+1, cx)
        try_open(cy-1, cx)
        #try_open(cy+1, cx+1)
        #try_open(cy+1, cx-1)
        #try_open(cy-1, cx+1)
        #try_open(cy-1, cx-1)

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
