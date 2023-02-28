import Base.Ordering
import Base.lt
import DataStructures.eq
using Profile
struct AStarOrdering <: Ordering end

lt(::AStarOrdering, (g1, h1, t1), (g2, h2, t2)) = g1 + h1 < g2 + h2 || g1 + h1 == g2 + h2 && t1 < t2


  function heuristic((y1,x1) :: Tuple{Int,Int}, (y2,x2) :: Tuple{Int,Int})
        dx = x2 - x1
        dy = y2 - y1
        return abs(dx) + abs(dy)
    end

    function tie_breaker((y1,x1) :: Tuple{Int,Int}, (y2,x2) :: Tuple{Int,Int}, target)
        dx1 = x2 - x1
        dy1 = y2 - y1
        
        ty,tx = target

        dx2 = tx - x1
        dy2 = ty - y1

        n = sqrt(dx2 ^ 2 + dy2 ^2)
        
        return (dx1 * dx2 + dy1 * dy2)/n 
    end

   
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

    open_cells = PriorityQueue{Tuple{Int,Int}, Tuple{Int,Float64,Float64}}(AStarOrdering())

    enqueue!(open_cells,start,(0,heuristic(start,target), 0))

    while current != target && length(open_cells) > 0

        current = dequeue!(open_cells)
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

            cost = Tiles.transition_costs[Int(type) + 1, Int(ntype) + 1]

            newlength =  pathlength+cost
            if states[ny,nx] == Unvisited
                enqueue!(open_cells, (ny,nx), (newlength,heuristic((ny,nx), target), tie_breaker((ny,nx),current, target)))
                states[ny,nx] = Opened
                parents[ny,nx] = current
                pathlengths[ny,nx] = newlength
            elseif states[ny,nx] == Opened && newlength < pathlengths[ny,nx]
                parents[ny,nx] = current
                pathlengths[ny,nx] = newlength
                open_cells[(ny,nx)] =  (newlength,heuristic((ny,nx), target), tie_breaker((ny,nx),current, target))            
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
