module AxisKeysExt
using AxisKeys: KeyedArray, axiskeys, dimnames
using PyPlotUtils
import PyPlotUtils: extent_ax, extent_arr, plot_ax, fill_between_ax, pcolormesh_ax

extent_arr(A::KeyedArray) = (extent_ax(axiskeys(A, 1))..., extent_ax(axiskeys(A, 2))...)

function plot_ax(A::KeyedArray; kwargs...)
    plt.plot(only(axiskeys(A)), A; kwargs...)
end

function fill_between_ax(A::KeyedArray; kwargs...)
    plt.fill_between(only(axiskeys(A)), leftendpoint.(A), rightendpoint.(A); kwargs...)
end

function pcolormesh_ax(A::KeyedArray; kwargs...)
    res = plt.pcolormesh(
        axiskeys(A, 1),
        axiskeys(A, 2),
        permutedims(A);
        kwargs...
    )
    set_xylabels(A)
    res
end

end
