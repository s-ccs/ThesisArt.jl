# [TextOnPath](@id init_example)

## TextOnPath

```@example main
using ThesisArt
using CairoMakie
using Random
nothing #hide
```

Let's define a (random) shape first

```@example main
my_points = 400 .* (rand(MersenneTwister(1),Point2f,20).-Point2f(0.5,0.5))
my_path = ThesisArt.points_to_bezierpath(my_points)
nothing #hide
```

And some random text

```@example main
using HTTP
my_text = String(HTTP.get("http://loripsum.net/api/verylong/plaintext").body)
my_text = replace(my_text,"\n"=>"")
```

```@example main

t = ThesisArt.TextOnPath(my_text,my_path)
CairoMakie.text(0,0;text=t)
```

## Color by glyph

if a color per glyph is provided, use that color

```@example main
c = CairoMakie.cgrad(:RdBu,500)|>collect|> x->x[1:500]
t = ThesisArt.TextOnPath(my_text[1:500],my_path)

CairoMakie.text(0,0;text=t,color=c)
```

## Color by segment

sometimes it is better to color by segment, where segments are divisions by `LineTo` and `MoveTo` in the path.

First we show how to make a break in the `BezierPath`

```@example main
my_points_split = Vector{Any}(deepcopy(my_points))
my_points_split[end÷2] = NaN
my_path_split = ThesisArt.points_to_bezierpath(my_points_split)
```

See how we have a `MoveTo` in the path? We introduced it by adding a `NaN` into our pointlist

Next, we introduce a color per segment

```@example main
t = ThesisArt.TextOnPath(my_text,my_path_split)

CairoMakie.text(0,0;text=t,color=repeat([:red,:blue],8+1),fontsize=5)

```
