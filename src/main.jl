using Colors
using ImageView
using Gtk.ShortNames 

include("Tiles.jl")
include("MapIO.jl")
include("Algorithms.jl")

function main(args)
    if length(args) != 7
        error("Wrong number of arguments.")
    end

    algo_dict =
        Dict(
            "dijkstra" => Algorithms.dijkstra,
            "a_star" => Algorithms.a_star
            )

    algorithm = args[1]
    filename = args[2]
    mode = args[3]
    if !(mode == "text" || mode == "picture")
        error("Expected \"text\" or \"picture\", got " * mode)
    end
    starty, startx = parse(Int,args[4]), parse(Int, args[5])
    targety, targetx = parse(Int,args[6]), parse(Int, args[7])

    start = (starty,startx)
    target = (targety,targetx)

    println("Loading map...")

    text_map :: Matrix{Char} = MapIO.load_map(filename)
    map :: Matrix{Tiles.TileType} = MapIO.convert_map(text_map)

    ymax,xmax = size(map)

    txt_colors = 
        Dict(
            'X' => :cyan,
            '+' => :green,
            '-' => :red,
            '@' => :white,
            'O' => :white,
            '.' => :black,
            'G' => :black,
            'S' => :orange,
            'W' => :blue,
            'T' => :yellow
            )

    img_colors = 
        Dict(
            'X' => RGB(0.0,1.0,1.0),
            '+' => RGB(0.0,1.0,0.0),
            '-' => RGB(1.0,0.0,0.0),
            '@' => RGB(0.0,0.0,0.0),
            'O' => RGB(0.0,0.0,0.0),
            '.' => RGB(0.965, 0.843, 0.690),
            'G' => RGB(0.965, 0.843, 0.690),
            'S' => RGB(0.0,.5,0.75),
            'W' => RGB(0.0,0.0,1.0),
            'T' => RGB(0.2,0.5409,0.112)
            )


    small_instance :: Matrix{Tiles.TileType}= fill(Tiles.Terrain, (2,2))

    if haskey(algo_dict, algorithm)
        println("Running " * algorithm * " once on a small instance to force compilation...")
        (_,_) = algo_dict[algorithm](small_instance, (1,1), (2,2), :return_visited)
        println("Launching search using " * algorithm * "...")
        t = @elapsed (path,visited) = algo_dict[algorithm](map, start, target, :return_visited)
        println("Finished in  : ", t, " seconds")
        println("Visited ", visited, " tiles")

        if !isempty(path)
            println("Found path of cost : ", Tiles.path_cost(map, path))
        else
            println("No path was found")
        end

        for (y,x) in path
            text_map[y,x] = 'X'
        end
        text_map[starty,startx] = '+'
        text_map[targety,targetx] = '-'
        if mode == "text"
            for y in 1:ymax
                for x in 1:xmax
                    c = text_map[y,x]
                    printstyled(stdout, c, color = txt_colors[c])
                end
                print('\n')
            end
        elseif mode == "picture"
            img = (c -> img_colors[c]).(text_map)
            cond = Condition()
            shw = imshow(img)
            win = shw["gui"]["window"]
            resize!(win, 1000, 800)
            signal_connect(win, :destroy) do widget
                notify(cond)
            end 
            wait(cond)
        end

    else
        error("Not a valid algorithm : " * algorithm)
    end
end

if !isinteractive()
    main(ARGS)
end
