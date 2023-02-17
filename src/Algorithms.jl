module Algorithms
    export djikstra
    using ..Tiles
    import DataStructures.PriorityQueue
    import DataStructures.enqueue!
    import DataStructures.dequeue_pair!

    @enum TileState Unvisited Opened Closed

    mutable struct Tile 
        type :: TileType
        state :: TileState
        parent :: Tuple{Int, Int}
        length :: Int
    end

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

            if cx < xmax && grid[cy,cx+1].type != Unpassable
                newlength =  pathlength+Tiles.transition_costs[Int(type) + 1, Int(grid[cy,cx+1].type) + 1]
                if grid[cy,cx+1].state == Unvisited
                    enqueue!(open_cells, (cy,cx+1), newlength)
                    grid[cy,cx+1].state = Opened
                    grid[cy,cx+1].parent = current
                    grid[cy,cx+1].length = newlength
                elseif grid[cy,cx+1].state == Opened && newlength < grid[cy,cx+1].length
                    grid[cy,cx+1].parent = current
                    grid[cy,cx+1].length = newlength
                end
            end

            if cx > 1 && grid[cy,cx-1].type != Unpassable
                newlength = pathlength+Tiles.transition_costs[Int(type) + 1, Int(grid[cy,cx-1].type) + 1]
                if grid[cy,cx-1].state == Unvisited
                    enqueue!(open_cells, (cy,cx-1), newlength)
                    grid[cy,cx-1].state = Opened
                    grid[cy,cx-1].parent = current
                    grid[cy,cx-1].length = newlength
                elseif grid[cy,cx-1].state == Opened && newlength < grid[cy,cx-1].length
                    grid[cy,cx-1].parent = current
                    grid[cy,cx-1].length = newlength
                end
            end

            if cy < ymax && grid[cy+1,cx].type != Unpassable
                newlength = pathlength+Tiles.transition_costs[Int(type) + 1, Int(grid[cy+1,cx].type) + 1]
                if grid[cy+1,cx].state == Unvisited
                    enqueue!(open_cells, (cy+1,cx), newlength)
                    grid[cy+1,cx].state = Opened
                    grid[cy+1,cx].parent = current
                    grid[cy+1,cx].length = newlength
                elseif grid[cy+1,cx].state == Opened && newlength < grid[cy+1,cx].length
                    grid[cy+1,cx].parent = current
                    grid[cy+1,cx].length = newlength
                end
            end
            
            if cy > 1 && grid[cy-1,cx].type != Unpassable
                newlength = pathlength+Tiles.transition_costs[Int(type) + 1, Int(grid[cy-1,cx].type) + 1]
                if grid[cy-1,cx].state == Unvisited
                    enqueue!(open_cells, (cy-1,cx), newlength)
                    grid[cy-1,cx].state = Opened
                    grid[cy-1,cx].parent = current
                    grid[cy-1,cx].length = newlength
                elseif grid[cy-1,cx].state == Opened && newlength < grid[cy-1,cx].length
                    grid[cy-1,cx].parent = current
                    grid[cy-1,cx].length = newlength
                end
            end


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
end
