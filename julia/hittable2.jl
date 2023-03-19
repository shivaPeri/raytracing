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

end