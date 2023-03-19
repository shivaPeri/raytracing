module HittableModule

export Hit_Record, Hit, Hittable, Hittable_List
export hit

include("utils.jl")
using .Utils

include("rays.jl")
using .Rays

# Hittable Class and associated methods
struct Hit_Record
    point::Point3
    normal::Vec3
    t::Float32
    front::Bool
    mat::Function
end

# Option type for Hit_Record
mutable struct Hit
    val::Union{Hit_Record, Nothing}
end

# constructors
Hit() = Hit(nothing)
Hit(p::Point3, n::Vec3, t::Float32, mat) = Hit(Hit_Record(p,n,t,true,mat))

abstract type Hittable end

# generic hit interface
function hit(obj::Hittable, ray::Ray, t_min::Float32, t_max::Float32)::Hit
    throw("unimplemented")
end

# Hittable List Class

struct Hittable_List <: Hittable
    objects::Vector{Hittable}
end


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
            rec = tmp
            closest_so_far = rec.val.t
        end
    end

    return rec
end

end