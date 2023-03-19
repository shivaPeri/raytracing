module Rays

using LinearAlgebra

include("utils.jl")
using .Utils

# Ray Class and associated methods

struct Ray
    origin::Point3
    direction::Vec3
end

Ray() = Ray(point3(), vec3())

function at(ray, t)
    return ray.origin .+ t * ray.direction
end

export Ray, at

end
