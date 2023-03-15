include("main.jl")

function algoDijkstra(fname :: String, D :: Tuple{Int64, Int64}, A :: Tuple{Int64,Int64})
    main(["dijkstra", fname, "picture", string(D[2]), string(D[1]), string(A[2]), string(A[1])])
end

function algoAstar(fname :: String, D :: Tuple{Int64, Int64}, A :: Tuple{Int64,Int64})
    main(["a_star", fname, "picture", string(D[2]), string(D[1]), string(A[2]), string(A[1])])
end
