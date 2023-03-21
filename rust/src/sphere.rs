use crate::ray::{HitRecord, Hittable, Ray};
use crate::vec3::{Point3, Vec3};

pub struct Sphere {
    center: Point3,
    radius: f32,
}

impl Sphere {
    pub fn new(center: Point3, radius: f32) -> Self {
        Sphere { center, radius }
    }
}

impl Hittable for Sphere {
    fn hit(&self, r: &Ray, t_min: f32, t_max: f32) -> Option<HitRecord> {
        let oc: Vec3 = r.origin - self.center;
        let a: f32 = r.direction.length_squared();
        let half_b: f32 = Vec3::dot(&oc, &r.direction);
        let c: f32 = oc.length_squared() - self.radius * self.radius;

        let discriminant = half_b * half_b - a * c;
        if discriminant < 0.0 {
            return None;
        }

        let sqrtd = discriminant.sqrt();
        let root = (-half_b - sqrtd) / a;
        if root < t_min || t_max < root {
            let root = (-half_b - sqrtd) / a;
            if root < t_min || t_max < root {
                return None;
            }
        }

        let point = r.at(root);
        let outward_normal = (point - self.center) / self.radius;

        let mut hr = HitRecord {
            p: r.at(root),
            normal: (r.at(root) - self.center) / self.radius,
            t: root,
            front_face: false,
        };

        hr.set_face_normal(r, outward_normal);
        return Some(hr);
    }
}
