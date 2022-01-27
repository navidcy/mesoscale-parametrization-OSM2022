# using Pkg
# pkg"add Oceananigans GLMakie"

ENV["GKSwstype"] = "100"

pushfirst!(LOAD_PATH, joinpath(@__DIR__, "..", ".."))

using Printf
using Statistics
using Plots

using Oceananigans
using Oceananigans.Units
using Oceananigans.OutputReaders: FieldTimeSeries
using Oceananigans.Grids: xnode, ynode, znode

const Lx = 1000kilometers # zonal domain length [m]
const Ly = 2000kilometers # meridional domain length [m]

# number of grid points
Nx = 200
Ny = 400
Nz = 35

# stretched grid 
k_center = collect(1:Nz)
Δz_center = @. 10 * 1.104^(Nz - k_center)
const Lz = sum(Δz_center)
z_faces = vcat([-Lz], -Lz .+ cumsum(Δz_center))
z_faces[Nz+1] = 0

arch = CPU()
FT = Float64

grid = VerticallyStretchedRectilinearGrid(architecture = arch,
                                          topology = (Periodic, Bounded, Bounded),
                                          size = (1, Ny, Nz),
                                          halo = (3, 3, 3),
                                          x = (0, Lx),
                                          y = (0, Ly),
                                          z_faces = z_faces)


grid = VerticallyStretchedRectilinearGrid(architecture = CPU(),
                                          topology = (Periodic, Bounded, Bounded),
                                          size = (grid.Nx, grid.Ny, grid.Nz),
                                          halo = (3, 3, 3),
                                          x = (0, grid.Lx),
                                          y = (0, grid.Ly),
                                          z_faces = z_faces)

xu, yu, zu = nodes((Face, Center, Center), grid)
xc, yc, zc = nodes((Center, Center, Center), grid)

u_timeseries = FieldTimeSeries("zonally_averaged_channel.jld2", "u", grid=grid)
b_timeseries = FieldTimeSeries("zonally_averaged_channel.jld2", "b", grid=grid)

@show b_timeseries

anim = @animate for i in length(b_timeseries.times)-15:length(b_timeseries.times)
    b = b_timeseries[i]
    u = u_timeseries[i]
    
    b_yz = interior(b)[1, :, :]
    u_yz = interior(u)[1, :, :]
    
    @show umax = max(1e-9, maximum(abs, u_yz))
    @show umax = maximum(abs, u_timeseries[:, :, :, :])
    @show bmax = max(1e-9, maximum(abs, b_yz))
    
    ulims = (-umax, umax) .* 0.8
    blims = (-bmax, bmax) .* 0.8
    
    ulevels = vcat([-umax], range(ulims[1], ulims[2], length=31), [umax])
    blevels = vcat([-bmax], range(blims[1], blims[2], length=31), [bmax])
    
    ylims = (0, grid.Ly) .* 1e-3
    zlims = (-grid.Lz, 0)

    u_yz_plot = contourf(yu * 1e-3, zu, u_yz',
                         xlabel = "y (km)",
                         ylabel = "z (m)",
                         aspectratio = :equal,
                         linewidth = 0,
                         levels = ulevels,
                         clims = ulims,
                         xlims = ylims,
                         ylims = zlims,
                         color = :balance)
    
    contour!(u_yz_plot,
             yc * 1e-3, zc, b_yz',
             linewidth = 1,
             color = :black,
             levels = blevels,
             legend = :none)
end

mp4(anim, "zonally_averaged_channel_small.mp4", fps = 8) # hide

