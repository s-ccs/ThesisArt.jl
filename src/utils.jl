function get_rotation(x,y)
    return .-vcat(0,atan.(x[1:end-1]-x[2:end],y[1:end-1]-y[2:end])).+π/2 #.*0.9 #.*-1
end


function newfigure(;resolution=(420,594),resolution_factor=1)
    f =  Figure(;resolution=resolution.*resolution_factor)
    return f
end

function addTitle!(ax,title,name,year)
    t1 = text!(ax,0.5,0.55,text=title,justification=:center,align=(:center,:center),font="Helvetica")
    t2 = text!(ax,0.85,0.05,text=[name*"\n"*year],position=[0,0],justification=:right,fontcolor="green",fontsize=7)
	xlims!(ax,(0,1.))
	ylims!(ax,(0,1.))
	return t1,t2
end

function addSpacer!(f,x,y,aspect;debug=false)
    if debug
        a = f[x,y]	 = Axis(f,backgroundcolor= "red")
    else
        a = f[x,y]	 = Axis(f)
    end
    if length(x) == 1
        # define a row
        rowsize!(f.layout, x, Aspect(1,aspect))
    else
        #define a col
        #colsize!(f.layout, y, Aspect(1,aspect))
    end
    hidedecorations!(a)
    hidespines!(a)
    return a
end


function rotationmatrix(α)
    return [cos(α) -sin(α);sin(α) cos(α)]
end
