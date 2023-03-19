module MaterialModule

export Lambertian, Metal, Dielectric

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

        scattered.origin .= rec.point
        scattered.direction .= scatter_dir
        attenuation .= albedo
        return true
    end

    return scatter
end

function Metal(albedo::Color, fuzz::Float64)::Function

    function scatter(r_in, rec, attenuation::Color, scattered)
        reflected = reflect(normalize(r_in.direction), rec.normal)
        scattered.origin .= rec.point
        scattered.direction .= reflected + fuzz * random_in_unit_sphere()
        attenuation .= albedo
        return dot(scattered.direction, rec.normal) > 0
    end

    return scatter
end

# Schlick's approximation for reflectance
function reflectance(cosine, ref_idx)
    rθ = (1-ref_idx) / (1 + ref_idx)
    rθ = rθ^2
    return rθ + (1-rθ) * (1-cosine)^5
end

# ir, index of refraction
function Dielectric(ir)

    function scatter(r_in, rec, attenuation::Color, scattered)
        attenuation .= color(1,1,1)
        refraction_ratio::Float32 = rec.front ? (1.0/ir) : ir

        unit_dir = normalize(r_in.direction)
        cosθ = min(dot(unit_dir, rec.normal), 1.0)
        sinθ = √(1.0 - cosθ^2)
        cannot_refract = refraction_ratio * sinθ > 1.0

        if cannot_refract || reflectance(cosθ, refraction_ratio) > rand()
            # cannot refract (no solution), must reflect
            direction = reflect(unit_dir, rec.normal)
        else
            # can refract    
            direction = refract(unit_dir, rec.normal, refraction_ratio)
        end
        

        scattered.origin .= rec.point
        scattered.direction .= direction
        return true
    end

    return scatter
end


end