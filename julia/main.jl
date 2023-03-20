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
        return color()
    end

    rec = HitRecord()
    if hit(world, ray, 0.0001, Inf64, rec)

        scattered = Ray()
        attenuation = color()

        if rec.mat(ray, rec, attenuation, scattered)
            return attenuation .* ray_color(scattered, world, depth-1)
        end
        return color()
    end

    # Background sky color
    unit_direction = normalize(ray.direction)
    t = 0.5 * (y(unit_direction) + 1.0)
    return (1.0-t) * color(1.0, 1.0, 1.0) + t * color(0.5, 0.7, 1.0);
end

# assumes 0-indexing
function unflatten(x, d1, d2, d3) 
    i = x ÷ (d2 * d3)
    j = (x - i * d1) ÷ d3
    k = x % d3
    return i, j, k
end

function main()

    # Image
    
    aspect_ratio = 16.0 / 9.0
    # image_width = 400
    image_width=50
    image_height = floor(Int, Float64(image_width) / aspect_ratio)
    samples_per_pixel = 100
    max_depth = 50
    debug = false

    # World

    R = cos(Base.π / 4)
    material_left = Lambertian(color(0,0,1))
    material_right = Lambertian(color(1,0,0))

    world::HittableList = HittableList([
        Sphere(point3(-R,0,-1), R, material_left)
        Sphere(point3(R,0,-1), R, material_right)
    ])

    # material_ground = Lambertian(color(.8, .8, 0))
    # # material_center = Lambertian(color(.7, .3, .3))
    # # material_left = Metal(color(.8, .8, .8), 0.3)
    # # material_center = Dielectric(1.5)
    # material_center = Lambertian(color(.1, .2, .5))
    # material_left = Dielectric(1.5)
    # material_right = Metal(color(.8, .6, .2), 1.0)
    
    # world::HittableList = HittableList([
    #     Sphere(point3(0, -100.5, -1), 100, material_ground),
    #     Sphere(point3(0,0,-1), 0.5, material_center),
    #     Sphere(point3(-1,0,-1), 0.5, material_left),
    #     # Sphere(point3(-1,0,-1), -0.4, material_left),
    #     Sphere(point3(1,0,-1), 0.5, material_right)
    # ])

    # Camera
    
    camera = Camera()
    # camera = Camera(point3(-2,-2,1), point3(0,0,-1), vec3(0,1,0), 90.0, aspect_ratio)
    # print(camera)
    
    # Render
    
    if !debug @printf "P3\n%d %d\n255\n" image_width image_height end

    iterations = image_height * image_width * samples_per_pixel
    pixel_color = color(0,0,0)
    
    for x in ProgressBar(1:iterations)

        j, i, s = unflatten(x, image_height, image_width, samples_per_pixel)
        j = image_height - j - 1 # reverse order

        if s == 0
            pixel_color .= 0
        end
                
        u = (Float64(i) + rand(Float64)) / (image_width-1)
        v = (Float64(j) + rand(Float64)) / (image_height-1)

        ray = get_ray(camera, u, v)
        pixel_color .+= ray_color(ray, world, max_depth)

        if s == samples_per_pixel - 1
            if !debug write_color(pixel_color, samples_per_pixel) end
        end

    end

end

main()