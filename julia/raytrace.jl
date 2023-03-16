using Printf
using Random
# using Parameters
using ProgressBars
using LinearAlgebra

include("utils.jl")
using .Utils

include("rays.jl")
using .Rays

include("camera.jl")
using .CameraModule

include("hittable.jl")
using .HittableObject

include("material.jl")
using .MaterialModule

# Sphere Class and associated methods
struct Sphere <: Hittable
    center::Point3
    radius::Float64
    mat::Function
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
    rec = Hit(point, normal, Float32(root),sphere.mat)
    return rec 
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

function ray_color(ray::Ray, world::Hittable, depth::Int)::Color

    # If we've exceeded the ray bounce limit, no more light is gathered.
    if depth <= 0
        return color(0,0,0)
    end

    rec = hit(world, ray, Float32(0.0001), Inf32)
    if rec.val != nothing

        scattered = Ray()
        attenuation = color()

        if rec.val.mat(ray, rec.val, attenuation, scattered)
            return attenuation .* ray_color(scattered, world, depth-1)
        end
        return color()
        
        # target = rec.val.point + random_in_unit_hemisphere(rec.val.normal)
        # return 0.5 * ray_color(Ray(rec.val.point, target - rec.val.point), world, depth-1)
    end

    unit_direction = normalize(ray.direction)
    t = 0.5 * (y(unit_direction) + 1.0)
    return (1.0-t) * color(1.0, 1.0, 1.0) + t * color(0.5, 0.7, 1.0);
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

    material_ground = Lambertian(color(.8, .8, 0))
    material_center = Lambertian(color(.7, .3, .3))
    material_left = Metal(color(.8, .8, .8))
    material_right = Metal(color(.8, .6, .2))
    
    world::Hittable_List = Hittable_List([
        Sphere(point3(0, -100.5, -1), 100, material_ground),
        Sphere(point3(0,0,-1), 0.5, material_center),
        Sphere(point3(-1,0,-1), 0.5, material_left),
        Sphere(point3(1,0,-1), 0.5, material_right)
        # Sphere(point3(0,0,-1), 0.5),
        # Sphere(point3(0,-100.5,-1), 100)
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