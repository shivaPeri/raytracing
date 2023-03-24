use crate::ray::Ray;
use crate::vec3::{Point3, Vec3};

pub struct Camera {
    origin: Point3,
    ll_corner: Point3,
    horizontal: Vec3,
    vertical: Vec3,
}

impl Camera {
    pub fn new(lookFrom: Point3, lookAt: Point3, vup: Vec3, vfov: f32, aspect_ratio: f32) -> Self {
        let theta = vfov.to_radians();
        let h = (theta / 2.0).tan();
        let viewport_height = 2.0 * h;
        let viewport_width = aspect_ratio * viewport_height;
        let focal_length = 1.0;

        let w = (lookFrom - lookAt).unit_vector();
        let u = Vec3::cross(&vup, &w).unit_vector();
        let v = Vec3::cross(&w, &u);

        let origin = lookFrom;
        let horizontal = viewport_width * u;
        let vertical = viewport_height * v;
        let ll_corner = origin - horizontal / 2. - vertical / 2. - w;

        Camera {
            origin,
            ll_corner,
            horizontal,
            vertical,
        }
    }

    pub fn get_ray(&self, u: f32, v: f32) -> Ray {
        Ray {
            origin: self.origin,
            direction: self.ll_corner + u * self.horizontal + v * self.vertical - self.origin,
        }
    }
}
