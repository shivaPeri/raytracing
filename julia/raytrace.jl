using Printf
using Random
using ProgressBars
using LinearAlgebra

include("utils.jl")
using .Utils

include("rays.jl")
using .Rays

include("camera.jl")
using .CameraModule

include("hittable.jl")
using .HittableModule

include("material.jl")
using .MaterialModule

function ray_color(ray, world::Hittable, depth::Int)::Color

    # If we've exceeded the ray bounce limit, no more light is gathered.
    if depth <= 0
        return color(0,0,0)
    end

    rec = HitRecord()
    if hit(world, ray, Float32(0.0001), Inf32, rec)

        scattered = Ray()
        attenuation = color()

        if rec.mat(ray, rec, attenuation, scattered)
            return attenuation .* ray_color(scattered, world, depth-1)
        end
        return color()
    end

    unit_direction = normalize(ray.direction)
    t = 0.5 * (y(unit_direction) + 1.0)
    return (1.0-t) * color(1.0, 1.0, 1.0) + t * color(0.5, 0.7, 1.0);
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
    # material_center = Lambertian(color(.7, .3, .3))
    # material_left = Metal(color(.8, .8, .8), 0.3)
    # material_center = Dielectric(1.5)
    material_center = Lambertian(color(.1, .2, .5))
    material_left = Dielectric(1.5)
    material_right = Metal(color(.8, .6, .2), 1.)
    
    world::Hittable_List = Hittable_List([
        Sphere(point3(0, -100.5, -1), 100, material_ground),
        Sphere(point3(0,0,-1), 0.5, material_center),
        Sphere(point3(-1,0,-1), 0.5, material_left),
        Sphere(point3(1,0,-1), 0.5, material_right)
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