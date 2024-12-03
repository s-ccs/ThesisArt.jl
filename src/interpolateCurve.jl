

# returns interpolator

function interp_spline(z; order = 2)
    t = range(0, 1, length = length(z))
    return interpolate(t, z, BSplineOrder(order), Natural())
end
# returns k x more points, interpolated x/y
function interp_curve(k, x; kwargs...)
    it = interp_spline(collect(x); kwargs...)
    r = range(0, 1, length = k * length(x))

    r = range(0.5 - 1 / (length(x) * 2 - 2), 0.5 + 1 / (length(x) * 2 - 2), length = k)
    return it.(r)

end
function rolling_interp(x; times = 5, winsize = 4, kwargs...)
    if length(x) == 2
        return range(x[1], x[2], length = times)
    end
    #if length(x)==3
    #winsize =3
    #end
    x = vcat(repeat(x[1:1], winsize ÷ 2), x, repeat(x[end:end], winsize ÷ 2))



    return vcat(rolling(x -> interp_curve(times, x; kwargs...), x, winsize)..., x[end])

end
function rolling_inter2d(x, y; minDist = 1, kwargs...)
    x = rolling_interp(x; kwargs...)
    y = rolling_interp(y; kwargs...)


    #ix = 1:length(x)
    return equalize_distance(x, y; minDist = minDist)
end

function equalize_distance(x, y; minDist = 1)
    dist = rolling(dist2, x, y, 2)
    sumdist = cumsum(dist)
    ix = vcat(0, findall(diff(floor.(sumdist ./ minDist)) .> 0), length(x) - 1) .+ 1
    return (; :x => x[ix], :y => y[ix])
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
