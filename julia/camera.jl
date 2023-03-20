module CameraModule

export Camera, get_ray

include("utils.jl")
include("rays.jl")
using .Utils
using .Rays
using LinearAlgebra

struct Camera
    origin::Point3
    lower_left_corner::Point3
    horizontal::Vec3
    vertical::Vec3
end

function Camera()
    aspect_ratio = 16.0 / 9.0
    viewport_height = 2.0
    viewport_width = aspect_ratio * viewport_height
    focal_length = 1.0

    origin = point3(0, 0, 0)
    horizontal = vec3(viewport_width, 0, 0)
    vertical = vec3(0, viewport_height, 0)
    lower_left_corner = origin - horizontal/2 - vertical/2 - vec3(0, 0, focal_length)

    return Camera(
        origin,
        lower_left_corner,
        horizontal,
        vertical
    )
end

function Camera(lookFrom::Point3, lookAt::Point3, vup::Vec3, vfov::Float64, aspect_ratio::Float64)

    θ = deg2rad(vfov)
    h = Base.tan(θ/2)
    viewport_height = 2.0 * h
    viewport_width = aspect_ratio * viewport_height

    w = normalize(lookFrom - lookAt)
    u = normalize(cross(vup, w))
    v = cross(w, u)
    
    focal_length = 1.0

    origin = copy(lookFrom)
    horizontal = viewport_width * u
    vertical = viewport_height * v
    lower_left_corner = origin - horizontal/2 - vertical/2 - w
     
    return Camera(
        origin,
        lower_left_corner,
        horizontal,
        vertical
    )
end

function get_ray(c::Camera, s::Float64, t::Float64)
    return Ray(c.origin, c.lower_left_corner + s*c.horizontal +  t*c.vertical - c.origin)
end

end
