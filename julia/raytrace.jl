using LinearAlgebra


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

# Ray Class and associated methods

struct Ray
    origin::Point3
    direction::Vec3
end

function at(ray::Ray, t)
    return ray.origin .+ t * ray.direction
end


# Hittable Class and associated methods

struct Hit_Record
    point::Point3
    normal::Vec3
    t::Float64
    front_face::Bool
end

# makes sure surface normals always point outwards
function set_face_normal(hr::Hit_Record, ray::Ray, outward_normal::Vec3)
    front_face = dot(r.direction, outward_normal) < 0
    hr.normal = front_face ? outward_normal : -outward_normal
end

# generic hit interface
function hit(obj::Hittable, ray::Ray, t_min::Float, t_max::Float, rec::Hit_Record)
    throw("unimplemented")
end

# Sphere Class and associated methods

struct Sphere <: Hittable
    center::Point3
    radius::Float64
end

function hit(sphere::Sphere, ray::Ray, t_min::Float, t_max::Float, rec::Hit_Record)
    oc = r.origin .- center
    a = norm(r.direction)^2
    half_b = dot(oc, r.direction)
    c = norm(oc)^2 - radius .* radius
    
    discriminant = half_b .* half_b - a .* c
    if discriminant < 0 return false end
    sqrtd = sqrt(discriminant)

    # Find the nearest root that lies in the acceptable range.
    root = (-half_b - sqrtd) / a
    if (root < t_min || t_max < root)
        root = (-half_b + sqrtd) / a
        if (root < t_min || t_max < root) 
            return false
        end
    end

    rec.t = root
    rec.point = at(ray, rec.t)
    rec.normal = (rec.point .- center) ./ radius

    return true
end

function hit_sphere(center, radius, r)
    oc = r.origin .- center
    a = norm(r.direction)^2
    half_b = dot(oc, r.direction)
    c = norm(oc)^2 - radius .* radius
    discriminant = half_b .* half_b - a .* c

    if discriminant < 0
        return -1.0
    else
        return (-half_b .- sqrt(discriminant) ) ./ a
    end

end

function ray_color(ray)

    t = hit_sphere(point3(0,0,-1), 0.5, ray)
    if t > 0
        N = normalize(at(ray, t) - vec3(0,0,-1))
        return 0.5 .* color(x(N)+1, y(N)+1, z(N)+1)
    end
    unit_direction = normalize(ray.direction)
    t = 0.5 * (y(unit_direction) + 1.0)
    return (1.0-t) * color(1.0, 1.0, 1.0) + t * color(0.5, 0.7, 1.0);
end

# Write the translated [0,255] value of each color component.
function write_color(pixel_color::Color, max=256)

    max = max - 0.001
    ir = floor(Int, max * x(pixel_color))
    ig = floor(Int, max * y(pixel_color))
    ib = floor(Int, max * z(pixel_color))
    
    println(ir, " ", ig, " ", ib)
end


function main()

    # Image
    
    aspect_ratio = 16.0 / 9.0
    image_width = 400
    image_height = floor(Int, Float32(image_width) / aspect_ratio)

    # Camera
    
    viewport_height = 2.0
    viewport_width = aspect_ratio * viewport_height
    focal_length = 1.0

    origin = point3(0, 0, 0)
    horizontal = vec3(viewport_width, 0, 0)
    vertical = vec3(0, viewport_height, 0)
    lower_left_corner = origin .- horizontal./2 .- vertical./2 .- vec3(0, 0, focal_length)

    # Render

    println("P3\n", image_width, " ", image_height, "\n255")

    for j in reverse(0:(image_height-1))
        for i in 0:(image_width-1)

            u = Float32(i) / (image_width-1)
            v = Float32(j) / (image_height-1)
            r = Ray(origin, lower_left_corner + u*horizontal + v*vertical - origin)
            pixel_color = ray_color(r)
            write_color(pixel_color)
        
        end
    end

end

main()