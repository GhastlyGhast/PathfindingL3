using Colors
using ImageView
using Gtk.ShortNames 

include("Tiles.jl")
include("MapIO.jl")
include("Algorithms.jl")

function main()
    if length(ARGS) != 7
        println("Wrong number of arguments.")
        exit(1)
    end

    algo_dict =
        Dict(
            "dijkstra" => Algorithms.dijkstra,
            "a_star" => Algorithms.a_star
            )

    algorithm = ARGS[1]
    filename = ARGS[2]
    mode = ARGS[3]
    if !(mode == "text" || mode == "picture")
        error("Expected \"text\" or \"picture\", got " * mode)
    end
    starty, startx = parse(Int,ARGS[4]), parse(Int, ARGS[5])
    targety, targetx = parse(Int,ARGS[6]), parse(Int, ARGS[7])

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

    if haskey(algo_dict, algorithm)
        println("Precompiling " * algorithm * "...")
        precompile(algo_dict[algorithm],(Matrix{Tiles.TileType}, Tuple{Int,Int}, Tuple{Int,Int}))
        println("Launching search using " * algorithm * "...")
        t = @elapsed path = algo_dict[algorithm](map, start, target)
        println("Finished in  : ", t, " seconds")
        println("Found path of cost : ", Tiles.path_cost(map, path))
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
            signal_connect(win, :destroy) do widget
                notify(cond)
            end
            
            wait(cond)
        end

    else
        error("Not a valid algorithm : " * algorithm)
    end

end

main()
