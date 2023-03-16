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

function at(ray::Ray, t)
    return ray.origin .+ t * ray.direction
end

# makes sure surface normals always point outwards
function set_face_normal(ray::Ray, outward_normal::Vec3)::Vec3
    front_face = dot(ray.direction, outward_normal) < 0
    return front_face ? outward_normal : -outward_normal
end

export Ray, at, set_face_normal

end
