using Printf
using Random
using Parameters
using ProgressBars
using LinearAlgebra

include("utils.jl")
using .Utils

include("rays.jl")
using .Rays

# Hittable Class and associated methods

struct Hit_Record
    point::Point3
    normal::Vec3
    t::Float32
end

# Option type for Hit_Record
mutable struct Hit
    val::Union{Hit_Record, Nothing}
end

# constructors
Hit() = Hit(nothing)
Hit(p::Point3, n::Vec3, t::Float32) = Hit(Hit_Record(p,n,t))

abstract type Hittable end

# generic hit interface
function hit(obj::Hittable, ray::Ray, t_min::Float32, t_max::Float32, rec::Hit_Record)::Hit
    throw("unimplemented")
end

# Sphere Class and associated methods

struct Sphere <: Hittable
    center::Point3
    radius::Float64
end

function random_in_unit_sphere()::Vec3
    while true
        p = rand(Float32, 3)
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

function hit(sphere::Sphere, ray::Ray, t_min::Float32, t_max::Float32)::Hit
    oc = ray.origin .- sphere.center
    a = norm(ray.direction)^2
    half_b = dot(oc, ray.direction)
    c = norm(oc)^2 - sphere.radius * sphere.radius
    
    discriminant = half_b * half_b - a * c
    if discriminant < 0 return Hit() end
    sqrtd = sqrt(discriminant)

    # Find the nearest root that lies in the acceptable range.
    root = (-half_b - sqrtd) / a
    if (root < t_min || t_max < root)
        root = (-half_b + sqrtd) / a
        if (root < t_min || t_max < root) 
            return Hit()
        end
    end

    point = at(ray, root)
    outward_normal = (point .- sphere.center) ./ sphere.radius
    normal = set_face_normal(ray, outward_normal)
    rec = Hit(point, normal, Float32(root))
    return rec 
end

# Hittable List Class

struct Hittable_List <: Hittable
    objects::Vector{Hittable}
end

function hit(world::Hittable_List, ray::Ray, t_min::Float32, t_max::Float32)::Hit

    rec = Hit()
    closest_so_far = t_max

    for object in world.objects
        tmp = hit(object, ray, t_min, closest_so_far)
        if tmp.val != nothing
            # rec = Hit(tmp.point, tmp.normal, tmp.t)
            rec = tmp
            closest_so_far = rec.val.t
        end
    end

    return rec
end

function ray_color(ray::Ray, world::Hittable, depth::Int)

    # If we've exceeded the ray bounce limit, no more light is gathered.
    if depth <= 0
        return color(0,0,0)
    end

    rec = hit(world, ray, Float32(0.0001), Inf32)
    if rec.val != nothing
        target = rec.val.point + random_in_unit_hemisphere(rec.val.normal)
        return 0.5 * ray_color(Ray(rec.val.point, target - rec.val.point), world, depth-1)
    end

    unit_direction = normalize(ray.direction)
    t = 0.5 * (y(unit_direction) + 1.0)
    return (1.0-t) * color(1.0, 1.0, 1.0) + t * color(0.5, 0.7, 1.0);
end


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

function get_ray(camera::Camera, u::Float32, v::Float32)
    return Ray(camera.origin, camera.lower_left_corner + u * camera.horizontal +  v * camera.vertical - camera.origin)
end


function main()

    # Image
    
    aspect_ratio = 16.0 / 9.0
    image_width = 400
    image_height = floor(Int, Float32(image_width) / aspect_ratio)
    samples_per_pixel = 100
    max_depth = 50

    # World
    
    world::Hittable_List = Hittable_List([
        Sphere(point3(0,0,-1), 0.5),
        Sphere(point3(0,-100.5,-1), 100)
    ])

    # Camera
    
    camera::Camera = Camera()
    
    # Render
    
    @printf "P3\n%d %d\n255\n" image_width image_height

    for j in ProgressBar(reverse(0:(image_height-1)))
        for i in 0:(image_width-1)

            pixel_color = color(0,0,0)

            for s in 1:samples_per_pixel
                
                u = (Float32(i) + rand(Float32)) / (image_width-1)
                v = (Float32(j) + rand(Float32)) / (image_height-1)

                ray = get_ray(camera, u, v)
                pixel_color .+= ray_color(ray, world, max_depth)
            end
            write_color(pixel_color, samples_per_pixel)
        end
    end
end

main()