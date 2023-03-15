module Camera_

export Camera

include("utils.jl")
using .Utils
include("rays.jl")
using .Rays
using Parameters

# Camera Class and associated methods
@with_kw struct Camera
    aspect_ratio::Float32 = 16.0 / 9.0
    viewport_height::Float32 = 2.0
    viewport_width::Float32 = aspect_ratio * viewport_height
    focal_length::Float32 = 1.0

    origin = point3(0, 0, 0)
    horizontal = vec3(viewport_width, 0, 0)
    vertical = vec3(0, viewport_height, 0)
    lower_left_corner = origin - horizontal/2 - vertical/2 - vec3(0, 0, focal_length)
end

end
