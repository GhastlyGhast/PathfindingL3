# PathfindingL3 

PathfindingL3 is a college project with the aim of implementing the Dijkstra and A\* pathfinding algorithms in Julia and to use them on data from https://movingai.com/benchmarks/grids.html

# Usage

There are two ways to use this project, either directly from the CLI or by importing it into a julia REPL

## CLI

There are two executable scripts in the src/ folder : 
+ src/main.jl that one lets you choose an algorithm, a map and the starting and ending points and gives you a graphical result by either displaying a picture in a separate window or printing the result on the standard output. It also gives you some statistics about the execution 
+ src/scen.jl that lets you run both of the algorithms on a series of instances given in a .scen file, it will assume that the map referenced in the scenario file is placed inside a folder names maps/

Here is the syntax for running each command
```
    julia src/main.jl <algorithm> <path_to_map> <output_mode> <start_y> <start_x> <end_y> <end_x>

        <algorithm>   : a_star, dijkstra
        <path_to_map> : relative path to the map file 
        <output_mode> : picture, text
        <start_y>     : integer between 1 and the height of the map
        <start_x>     : integer between 1 and the width of the map
        <end_y>       : integer between 1 and the height of the map
        <end_x>       : integer between 1 and the width of the map
    
    julia src/scen.jl <path_to_scenario> [verbosity]

        <path_to_scenario> : relative path to the scenario file 
        [verbosity]        : verbose, quiet
            default = quiet
```

## Wrapper functions

To comply with the assignment the file src/wrappers.jl also provides two wrapper functions 'algoDijkstra' and 'algoAstar' that can be called like so :
```julia
    algoDijkstra("path/to/file.map", (start_x, start_y), (end_x, end_y))
    
    algoAstar("path/to/file.map", (start_x, start_y), (end_x, end_y))
```

# Dependencies

The project depends on :
+ Colors.jl
+ Gtk.jl
+ DataStructures.jl
+ ImageView.jl

You should normally be able to install the needed dependencies using the Project.toml and Manifest.toml files at the root of the project after activating it.
