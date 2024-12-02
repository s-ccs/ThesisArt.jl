function get_rotation(x, y)
    return .-vcat(0, atan.(x[1:end-1] - x[2:end], y[1:end-1] - y[2:end])) .+ π / 2 #.*0.9 #.*-1
end


function newfigure(; size = (420, 594), size_factor = 1, kwargs...)
    f = Figure(; size = size .* size_factor, kwargs...)
    ax = f[1, 1] = Axis(f)
    hidespines!(ax)
    hidedecorations!(ax)
    return f, ax
end

function add_title!(f, title, name, year)
    ##return (1, 1), 2
    ax = add_spacer!(f, 2, 1, 0.3; debug = false)
    t1 = text!(
        ax,
        0.5,
        0.55,
        text = title,
        justification = :center,
        align = (:center, :center),
        font = "Helvetica",
    )
    t2 = text!(
        ax,
        0.85,
        0.05,
        text = [name * "\n" * string(year)],
        position = [0, 0],
        justification = :right,
        color = "#888",
        fontsize = 7,
    )
    xlims!(ax, (0, 1.0))
    ylims!(ax, (0, 1.0))
    return (t1, t2, ax)
end

function add_spacer!(f, row, col, aspect; debug = false)
    if debug
        a = f[row, col] = Axis(f, backgroundcolor = "red")
    else
        a = f[row, col] = Axis(f)
    end
    if length(row) == 1
        # define a row
        rowsize!(f.layout, row, Aspect(1, aspect))
    else
        #define a col
        #colsize!(f.layout, y, Aspect(1,aspect))
    end
    hidedecorations!(a)
    hidespines!(a)
    return a
end


function rotationmatrix(α)
    return [cos(α) -sin(α); sin(α) cos(α)]
end
