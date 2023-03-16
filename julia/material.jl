module MaterialModule

export Lambertian, Metal

include("utils.jl")
using .Utils
include("rays.jl")
using .Rays

using LinearAlgebra


# a Material is a function which
# returns a scatter function based on input(s)

function Lambertian(albedo::Color)::Function

    function scatter(r_in, rec, attenuation::Color, scattered)
        scatter_dir = rec.normal + random_unit_vector()
        if near_zero(scatter_dir)
            scatter_dir = rec.normal
        end

        tmp = Ray(rec.point, scatter_dir)
        scattered.direction .= tmp.direction
        scattered.origin .= tmp.origin
        attenuation .= albedo
        return true
    end

    return scatter
end

function Metal(albedo::Color)::Function

    function scatter(r_in, rec, attenuation::Color, scattered)
        reflected = reflect(normalize(r_in.direction), rec.normal)
        tmp = Ray(rec.point, reflected)
        scattered.direction .= tmp.direction
        scattered.origin .= tmp.origin
        attenuation .= albedo
        return dot(scattered.direction, rec.normal) > 0
    end

    return scatter
end

end