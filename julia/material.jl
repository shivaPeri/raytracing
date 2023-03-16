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
        
        scattered.direction[1] = tmp.direction[1]
        scattered.direction[2] = tmp.direction[2]
        scattered.direction[3] = tmp.direction[3]
        scattered.origin[1] = tmp.origin[1]
        scattered.origin[2] = tmp.origin[2]
        scattered.origin[3] = tmp.origin[3]

        attenuation[1] = albedo[1]
        attenuation[2] = albedo[2]
        attenuation[3] = albedo[3]
        return true
    end

    return scatter
end

function Metal(albedo::Color)::Function

    function scatter(r_in, rec, attenuation::Color, scattered)
        reflected = reflect(normalize(r_in.direction), rec.normal)        
        
        tmp = Ray(rec.point, reflected)
        scattered.direction[1] = tmp.direction[1]
        scattered.direction[2] = tmp.direction[2]
        scattered.direction[3] = tmp.direction[3]
        scattered.origin[1] = tmp.origin[1]
        scattered.origin[2] = tmp.origin[2]
        scattered.origin[3] = tmp.origin[3]

        attenuation[1] = albedo[1]
        attenuation[2] = albedo[2]
        attenuation[3] = albedo[3]
        return dot(scattered.direction, rec.normal) > 0
    end

    return scatter
end

end