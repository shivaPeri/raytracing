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

function Camera(lookFrom::Point3, lookAt::Point3, vup::Vec3, vfov, aspect_ratio)

    θ = deg2rad(vfov)
    h = tan(θ/2)
    viewport_height = 2.0 * h
    viewport_width = aspect_ratio * viewport_height

    w = normalize(lookFrom - lookAt)
    u = normalize(cross(vup, w))
    v = cross(w, u)
    
    focal_length = 1.0

    origin = lookFrom
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

function get_ray(camera::Camera, u::Float32, v::Float32)
    return Ray(camera.origin, camera.lower_left_corner + u * camera.horizontal +  v * camera.vertical - camera.origin)
end

end
