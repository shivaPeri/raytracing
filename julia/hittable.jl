module HittableModule

export HitRecord, Hittable, HittableList
export set_face_normal
export Sphere
export hit

include("utils.jl")
using .Utils

include("rays.jl")
using .Rays

using LinearAlgebra

# Hittable Class and associated methods
mutable struct HitRecord
    point::Point3
    normal::Vec3
    t::Float32
    front::Bool
    mat::Function
end

# store the orientation of the face wrt. the ray
# makes sure surface normals always point outwards
function set_face_normal(rec::HitRecord, ray, outward_normal)
    rec.front = dot(ray.direction, outward_normal) < 0
    rec.normal .= rec.front ? outward_normal : -outward_normal
end

no_mat(a,b,c,d) = false
HitRecord() = HitRecord(point3(),vec3(),0.,true,no_mat)
HitRecord(p::Point3, n::Vec3, t::Float32, mat::Function) = HitRecord(p,n,t,true,mat)

abstract type Hittable end

# generic hit interface
function hit(obj::Hittable, ray, t_min::Float32, t_max::Float32)
    throw("unimplemented")
end

# Hittable List Class

struct HittableList <: Hittable
    objects::Vector{Hittable}
end


# Sphere Class and associated methods
struct Sphere <: Hittable
    center::Point3
    radius::Float64
    mat::Function
end

function hit(sphere::Sphere, ray, t_min::Float32, t_max::Float32, rec::HitRecord)::Bool
    oc = ray.origin .- sphere.center
    a = norm(ray.direction)^2
    half_b = dot(oc, ray.direction)
    c = norm(oc)^2 - sphere.radius * sphere.radius
    
    discriminant = half_b * half_b - a * c
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

    # populate the HitRecord data fields
    rec.t = Float32(root)
    rec.point .= at(ray, root)
    outward_normal = (rec.point - sphere.center) / sphere.radius
    set_face_normal(rec, ray, outward_normal)
    rec.mat = sphere.mat

    return true
end

function hit(world::HittableList, ray, t_min::Float32, t_max::Float32, rec::HitRecord)::Bool

    hit_anything = false
    tmp = HitRecord()
    closest_so_far = t_max

    for object in world.objects
        if hit(object, ray, t_min, closest_so_far, tmp)
            hit_anything = true
            closest_so_far = tmp.t
            rec.point .= tmp.point
            rec.normal .= tmp.normal
            rec.t = tmp.t
            rec.mat = tmp.mat
            rec.front = tmp.front
        end
    end

    return hit_anything
end

end