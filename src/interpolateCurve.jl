

# returns interpolator

function interpolate_spline(z; order = 4)
    t = range(0, 1, length = length(z))
    return interpolate(t, z, BSplineOrder(order), Natural())
end
# returns k x more points, interpolated x/y
function interpolate_curve(k, x; kwargs...)
    it = interpolate_spline(collect(x); kwargs...)
    r = range(0, 1, length = k * length(x))

    r = range(0.5 - 1 / (length(x) * 2 - 2), 0.5 + 1 / (length(x) * 2 - 2), length = k)
    return it.(r)

end

"""

Interpolates in 1D or 2D using BSplineOrder(order=4) the x/y path.

# arguments
x: Vector of Numeric, or vector of Point2f
[y: if x/y pairs are provided, will call the function on both axes individually]

# keyword
`winsize=4`: Over how many samples the interpolation function should run. For order =4, needs to be at least 4. For higher orders you need to increase this - you might get better interpolation by raising this, but i'm not sure.
`subsample=5`: How many points to evaluate the spline on, effectively how many intermediate points to return.
`order=4` the order of the BSPline. 4 is default, 2 is linear.
"""
function rolling_interpolation(x; subsample = 5, winsize = 4, kwargs...)
    if length(x) == 2
        return range(x[1], x[2], length = subsample)
    end
    #if length(x)==3
    #winsize =3
    #end
    x = vcat(repeat(x[1:1], winsize ÷ 2), x, repeat(x[end:end], winsize ÷ 2))



    return vcat(
        rolling(x -> interpolate_curve(subsample, x; kwargs...), x, winsize)...,
        x[end],
    )

end
rolling_interpolation(x::Vector{Point2f}; kwargs...) =
    Point2f.(rolling_interpolation(first.(x), last.(x); kwargs...)...)

function rolling_interpolation(x, y; kwargs...)
    x = rolling_interpolation(x; kwargs...)
    y = rolling_interpolation(y; kwargs...)



    return x, y
end

equalize_distance(p::Vector{Point2f}; kwargs...) =
    Point2f.(equalize_distance(first.(p), last.(p); kwargs...)...)
function equalize_distance(x, y; min_dist = 1)
    dist = rolling(dist2, x, y, 2)
    sumdist = cumsum(dist)
    ix = vcat(0, findall(diff(floor.(sumdist ./ min_dist)) .> 0), length(x) - 1) .+ 1
    return x[ix], y[ix]
end
function dist2(x, y)
    return sqrt((x[1] - x[2])^2 + (y[1] - y[2])^2)
end



#----
function points_to_bezierpath(points)
    _point_to_svg =
        (prev, p, pnext) -> isnan(prev) ? nothing : isnan(p) ? MoveTo(pnext) : LineTo(p)
    ix = length(points)
    #points = vcat(NaN, NaN, points)
    vec_lineto = _point_to_svg.(points[1:ix-2], points[2:ix-1], points[3:ix])
    vec_lineto = vec_lineto[.!isnothing.(vec_lineto)]
    return BezierPath(vec_lineto)
end
