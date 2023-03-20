module Utils

export Point3, Vec3, Color
export point3, vec3, color
export x, y, z
export random_unit_vector, random_in_unit_sphere, random_in_unit_hemisphere
export reflect, refract, near_zero, write_color

using Printf
using LinearAlgebra

# Add Type Aliases for relevant types
Point3 = Array{Float64,1}
Vec3 = Array{Float64,1}
Color = Array{Float64,1}

point3() = Point3([0,0,0])
vec3() = Vec3([0,0,0])
color() = Color([0,0,0])

point3(x, y, z) = Point3([x,y,z])
vec3(x, y, z) = Vec3([x,y,z])
color(x, y, z) = Color([x,y,z])

# Accessor methods
x = v -> v[1]
y = v -> v[2]
z = v -> v[3]

# Random vector methods
function random_in_unit_sphere()::Vec3
    while true
        p = rand(Float64, 3)
        if norm(p) >= 1 continue end
        return p
    end
end

function random_unit_vector()::Vec3
    p = random_in_unit_sphere()
    return p / norm(p)
end

function random_in_unit_hemisphere(normal::Vec3)::Vec3
    p = random_in_unit_sphere()
    if (dot(p, normal) > 0.0) # In the same hemisphere as the normal
        return p
    else
        return -p
    end
end

function near_zero(e::Vec3)::Bool
    s = 1e-8
    return (abs(e[1]) < s) && (abs(e[2]) < s) && (abs(e[3]) < s);
end

# basic geometry
function reflect(v::Vec3, n::Vec3)::Vec3
    return v - 2 * dot(v, n) * n
end

# based on Snell's Law
function refract(uv::Vec3, n::Vec3, η_i_over_η_t::Float64)::Vec3
    cosθ = min(1.0, dot(-uv, n))
    r_perp = η_i_over_η_t * (uv + cosθ * n)
    r_parallel = -√(abs(1.0 - norm(r_perp)^2)) * n
    return r_perp + r_parallel
end

# Write the translated [0,255] value of each color component.
function write_color(pixel_color::Color, samples::Int)

    r, g, b = x(pixel_color), y(pixel_color), z(pixel_color)

    # Divide the color by the number of samples and gamma-correct for gamma=2.0.
    scale = 1.0 / Float64(samples)
    r = sqrt(scale * r)
    g = sqrt(scale * g)
    b = sqrt(scale * b)

    max = 256
    ir = floor(Int, max * clamp(r, 0, 0.999))
    ig = floor(Int, max * clamp(g, 0, 0.999))
    ib = floor(Int, max * clamp(b, 0, 0.999))

    @printf "%d %d %d\n" ir ig ib
end

end