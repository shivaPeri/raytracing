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

mutable struct Hit_Record
    point::Point3
    normal::Vec3
    t::Float32
    front_face::Bool
end

# makes sure surface normals always point outwards
function set_face_normal(hr::Hit_Record, ray::Ray, outward_normal::Vec3)
    front_face = dot(ray.direction, outward_normal) < 0
    hr.normal = front_face ? outward_normal : -outward_normal
end

abstract type Hittable end

# generic hit interface
function hit(obj::Hittable, ray::Ray, t_min::Float32, t_max::Float32, rec::Hit_Record)
    throw("unimplemented")
end

# Sphere Class and associated methods

struct Sphere <: Hittable
    center::Point3
    radius::Float64
end

function hit(sphere::Sphere, ray::Ray, t_min::Float32, t_max::Float32, rec::Hit_Record)::Bool
    oc = ray.origin .- sphere.center
    a = norm(ray.direction)^2
    half_b = dot(oc, ray.direction)
    c = norm(oc)^2 - sphere.radius .* sphere.radius
    
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

    outward_normal = (rec.point .- sphere.center) ./ sphere.radius
    rec.normal = set_face_normal(rec, ray, outward_normal)
    
    return true
end

function hit_sphere(center, radius, r)::Float32
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

# Hittable List Class

struct Hittable_List <: Hittable
    objects::Vector{Hittable}
end

function hit(objects::Hittable_List, ray::Ray, t_min::Float32, t_max::Float32, rec::Hit_Record)::Bool

    temp_rec = Hit_Record(point3(0,0,0), vec3(0,0,0), 0., false)
    hit_anything = false
    closest_so_far = t_max


    for object in objects.objects
        if hit(object, ray, t_min, closest_so_far, temp_rec)
            hit_anything = true
            closest_so_far = temp_rec.t
            rec = temp_rec
        end
    end

    return hit_anything
end

function ray_color(ray::Ray, world::Hittable)

    rec = Hit_Record(point3(0,0,0), vec3(0,0,0), 0., false)
    if hit(world, ray, Float32(0), Inf32, rec)
        return 0.5 * (rec.normal + color(1,1,1))
    end

    # t = hit_sphere(point3(0,0,-1), 0.5, ray)
    # if t > 0
    #     N = normalize(at(ray, t) - vec3(0,0,-1))
    #     return 0.5 .* color(x(N)+1, y(N)+1, z(N)+1)
    # end
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

    # World
    
    world::Hittable_List = Hittable_List([
        Sphere(point3(0,0,-1), 0.5),
        Sphere(point3(0,-100.5,-1), 100)
    ])

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
            pixel_color = ray_color(r, world)
            write_color(pixel_color)
        
        end
    end

end

main()