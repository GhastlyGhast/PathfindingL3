import Base.Ordering
import Base.lt
import DataStructures.eq

struct AStarOrdering <: Ordering end

lt(::AStarOrdering, (g1, h1), (g2, h2)) = h1 + g1 < h2 + g2 || h1 + g1 == h2 + g2 && h1 < h2

function heuristic((y1,x1) :: Tuple{Int,Int}, (y2,x2) :: Tuple{Int,Int})
    dx = x2 - x1
    dy = y2 - y1
    return abs(dx) + abs(dy)
end
   
function a_star(map :: Matrix{TileType}, 
                start :: Tuple{Int,Int}, 
                target :: Tuple{Int,Int},
                mode :: Symbol = :only_path
               )

    ymax, xmax = size(map)

    #Broadcast is lazy so we must do this
    types = map
    parents = fill((0,0), size(map))
    pathlengths = fill(0, size(map))
    states = fill(Unvisited, size(map))
    visited = 0

    current = start

    open_cells = PriorityQueue{Tuple{Int,Int}, Tuple{Int,Int}}(AStarOrdering())

    enqueue!(open_cells,start,(0,heuristic(start,target)))

    while current != target && length(open_cells) > 0

        current = dequeue!(open_cells)
        cy, cx = current
        type = types[cy, cx]
        pathlength = pathlengths[cy, cx]

        neighbours = [(cy+1,cx), (cy-1,cx), (cy, cx+1), (cy, cx-1)]
        #neighbours = [(cy,cx - 1), (cy,cx + 1), (cy - 1, cx+1), (cy + 1, cx)]

        for (ny,nx) in neighbours 
            if nx < 1 || ny < 1 || nx > xmax || ny > ymax 
                continue
            end

            ntype = types[ny,nx]
            if !Tiles.transition_possible[Int(type), Int(ntype)]
                continue
            end

            cost = Tiles.transition_costs[Int(type), Int(ntype)]

            newlength =  pathlength+cost
            if states[ny,nx] == Unvisited
                enqueue!(open_cells, (ny,nx), (newlength, heuristic((ny,nx), target)))
                states[ny,nx] = Opened
                parents[ny,nx] = current
                pathlengths[ny,nx] = newlength
                visited += 1
            elseif states[ny,nx] == Opened && newlength < pathlengths[ny,nx]
                parents[ny,nx] = current
                pathlengths[ny,nx] = newlength
                open_cells[(ny,nx)] =  (newlength, heuristic((ny,nx), target))            
            end
        end
        
        states[cy,cx] = Closed

    end

    path = Tuple{Int,Int}[]

    if current == target
    
        while current != start
            pushfirst!(path,current) 
            cy, cx = current
            current = parents[cy, cx]
        end
        pushfirst!(path,start)
    end
    if mode == :only_path
        return path
    else
        return path,visited
    end


end
