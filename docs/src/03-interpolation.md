# [Interpolation](@id interpolate)

## Interpolation

```@example main
using ThesisArt
using CairoMakie
using Random
nothing #hide
```

Let's define a (random) shape first

```@example main
my_points = 400 .* (rand(MersenneTwister(1),Point2f,20).-Point2f(0.5,0.5))
nothing #hide
```

```@example main
scatterlines(my_points)
```

The lines are not that nice. Let's interpolate them

## order setting

```@example ax_main
my_xy_interpolated_2 =ThesisArt.rolling_interpolation(my_points;order=2)
my_xy_interpolated_4 =ThesisArt.rolling_interpolation(my_points;order=4) # default
```

```@example main
f = Figure()
scatterlines(f[1,1],my_xy_interpolated_2,axis=(;title="Order 2"))
scatter!(my_points,color=:red)
scatterlines(f[1,2],my_xy_interpolated_4,axis=(;title="Order 4"))
scatter!(my_points,color=:red)
f
```

We see left linear interpolation, right cubic interpolation.

## subsample

```@example main
my_xy_interpolated_20 =ThesisArt.rolling_interpolation(my_points;subsample=20)
my_xy_interpolated_5 =ThesisArt.rolling_interpolation(my_points;subsample=5) #
```

```@example main
f = Figure()
scatterlines(f[1,1],my_xy_interpolated_5,axis=(;title="subsample 5"))
scatter!(my_points,color=:red)
scatterlines(f[1,2],my_xy_interpolated_20,axis=(;title="subsample 20"))
scatter!(my_points,color=:red)
f
```

## Equalize distance

```@example main
my_xy_interpolated_100 =ThesisArt.rolling_interpolation(my_points;subsample=100)

my_xy_equ_10 = equalize_distance(my_xy_interpolated_100,min_dist=10)
my_xy_equ_50 = equalize_distance(my_xy_interpolated_100,min_dist=50)
```

```@example main
f = Figure()
scatterlines(f[1,1],my_xy_equ_10,axis=(;title="mindist 10"))
scatter!(my_points,color=:red)
scatterlines(f[1,2],my_xy_equ_50,axis=(;title="mindist 50"))
scatter!(my_points,color=:red)
f
```
