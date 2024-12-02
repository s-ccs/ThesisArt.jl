using BenchmarkTools
using Observables
using GLMakie


d = rand(50, 100000);

# n = 1 : 10

function plt_lines(ax, d, n)
    for ch = 1:50
        lines!(ax, @lift((d[ch, (($n-1)*10000+1):($n*19000)])), color = "black")
    end
end
function plt_series(ax, d, n)
    series!(ax, lift(k -> d[:, ((k-1)*10000+1):(k*10000)], n), solid_color = :black)
end
n = Observable(1)
testwhich = "series"


f = Figure()
ax = f[1, 1] = Axis(f)

#@time plt_series(ax,d,n) # 0.009s / 0.5s
@time plt_lines(ax, d, n)
@time display(f) # 0.013s / 0.13s

@time @time begin
    n[] = 3
end
