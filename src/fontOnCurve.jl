"""
Code written mostly by Julius Krumbiegel with some modifications by Benedikt Ehinger

# Important: Don't provide a closed path, it can lead to infinite loops
"""
struct TextOnPath
    text::String
    path::Makie.BezierPath
end

function Makie._get_glyphcollection_and_linesegments(
    top::TextOnPath,
    index,
    ts,
    f,
    fs,
    al,
    rot,
    jus,
    lh,
    col,
    scol,
    swi,
    www,
    offs,
)
    gc = Makie.layout_text(top, ts, f, fs, al, rot, jus, lh, col, scol, swi)
    gc, Point2f[], Float32[], RGBAf[], Int[]
end

"""
returns the attribute per character - if the length of the attribute does not equal to the length of the string, AND it equals to the number of points from the BezierPath - we will use the attribute per segment (until a MoveTo / NaN segment)

Note: currently only works for LineTo and MoveTo - not Curve, as Curve interpolates 30points per curve!
"""
attribute_per_char_or_segment(string, attr, lengthPoints) =
    Makie.attribute_per_char(string, attr)
function attribute_per_char_or_segment(string, attr::AbstractVector, lengthPoints)
    @debug lengthPoints, length(attr), length(string)
    if (length(attr) !== length(string)) & (length(attr) == lengthPoints)
        @assert all(isa.([MoveTo(1, 2), LineTo(1, 2)], Union{MoveTo,LineTo})) "Currently no support for BezierSegments other than MoveTo and LineTo"
        return attr
    else
        return Makie.attribute_per_char(string, attr)

    end
end
function Makie.layout_text(top::TextOnPath, ts, f, fs, al, rot, jus, lh, col, scol, swi)
    points = only(Makie.convert_arguments(PointBased(), top.path))

    ft_font = Makie.to_font(f)
    rscale = Makie.to_fontsize(ts)


    colors = attribute_per_char_or_segment(top.text, col, length(points))
    strokecolors = attribute_per_char_or_segment(top.text, scol, length(points))
    strokewidths = attribute_per_char_or_segment(top.text, swi, length(points))
    fonts = attribute_per_char_or_segment(top.text, ft_font, length(points))
    fontsizes = attribute_per_char_or_segment(top.text, rscale, length(points))

    gc = glyph_collection_on_path(
        points,
        top.text,
        fonts,
        fontsizes,
        colors,
        strokecolors,
        strokewidths,
    )
end

function glyph_collection_on_path(
    points,
    text,
    fonts,
    fontsizes,
    colors,
    strokecolors,
    strokewidths,
)
    glyphinfos = Makie.GlyphInfo[]

    seg = 1
    at_fraction::Float64 = 0.0


    get_attr(attr::Base.Generator, ix_char, seg) = collect(attr)[1]
    get_attr(attr, ix_char, seg) = attr


    function get_attr(attr::AbstractVector, ix_char, seg)

        if length(attr) == length(text)
            return attr[ix_char]
        else
            return attr[seg]
        end
    end
    for (ix_char, char) in enumerate(collect(text))

        font = get_attr(fonts, ix_char, seg)
        fontsize = get_attr(fontsizes, ix_char, seg)
        strokecolor = get_attr(strokecolors, ix_char, seg)
        strokewidth = get_attr(strokewidths, ix_char, seg)
        color = get_attr(colors, ix_char, seg)

        v = points[seg+1] - points[seg]
        p = points[seg] + v * at_fraction

        ext = Makie.GlyphExtent(font, char)
        sz = Vec2f(fontsize, fontsize)

        hadvance = ext.hadvance * sz[1]

        # find next point
        accumulated = 0.0
        while true
            if isnan(points[seg+1]) | isnan(points[seg])
                seg += 1
                continue
            end

            seglength = Makie.norm(points[seg+1] - points[seg])
            remaining_this_seg = (1 - at_fraction) * seglength
            to_go = hadvance - (accumulated + remaining_this_seg)
            if to_go <= 0
                at_fraction = 1 - (-to_go / seglength)
                break
            else
                accumulated += remaining_this_seg
                at_fraction = 0.0
                if seg < length(points) - 1
                    seg += 1
                end
            end
        end

        gi = Makie.GlyphInfo(
            Makie.FreeTypeAbstraction.glyph_index(font, char),
            font,
            p,
            ext,
            sz,
            Makie.to_rotation(reverse(v) .* (-1, 1)),
            color,
            strokecolor,
            strokewidth,
        )
        push!(glyphinfos, gi)
        if seg >= length(points) - 1
            @warn "Could not fit all characters on path, you could reduce the fontsize"
            break
        end
    end
    #@show seg, size(glyphinfos)
    return Makie.GlyphCollection(glyphinfos)
end
