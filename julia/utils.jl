module Utils

using Printf

# Add Type Aliases for relevant types
Point3 = Array{Float64,1}
Vec3 = Array{Float64,1}
Color = Array{Float64,1}

point3(x, y, z) = Point3([x,y,z])
vec3(x, y, z) = Vec3([x,y,z])
color(x, y, z) = Color([x,y,z])

# Accessor methods
x = v -> v[1]
y = v -> v[2]
z = v -> v[3]


# Write the translated [0,255] value of each color component.
function write_color(pixel_color::Color, samples::Int)

    r, g, b = x(pixel_color), y(pixel_color), z(pixel_color)

    # Divide the color by the number of samples and gamma-correct for gamma=2.0.
    scale = 1.0 / Float32(samples)
    r = sqrt(scale * r)
    g = sqrt(scale * g)
    b = sqrt(scale * b)

    max = 256
    ir = floor(Int, max * clamp(r, 0, 0.999))
    ig = floor(Int, max * clamp(g, 0, 0.999))
    ib = floor(Int, max * clamp(b, 0, 0.999))

    @printf "%d %d %d\n" ir ig ib
end

export Point3, Vec3, Color
export point3, vec3, color
export x, y, z
export write_color

end