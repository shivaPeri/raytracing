use crate::ray::{HitRecord, Ray};
use crate::vec3::{Color, Point3, Vec3};

// returns scattered ray (if its exists) and attenuation
pub trait Scatter {
    fn scatter(&self, r_in: &Ray, hr: &HitRecord) -> Option<(Option<Ray>, Color)>;
}

#[derive(Clone, Copy)]
pub enum Material {
    Lambertian(Lambertian),
    Metal(Metal),
}

impl Scatter for Material {
    fn scatter(&self, r_in: &Ray, hr: &HitRecord) -> Option<(Option<Ray>, Color)> {
        match self {
            Material::Lambertian(x) => x.scatter(r_in, hr),
            Material::Metal(x) => x.scatter(r_in, hr),
        }
    }
}

#[derive(Clone, Copy)]
pub struct Lambertian {
    pub albedo: Color,
}

impl Lambertian {
    pub fn new(albedo: Color) -> Self {
        Lambertian { albedo }
    }
}

impl Scatter for Lambertian {
    fn scatter(&self, r_in: &Ray, hr: &HitRecord) -> Option<(Option<Ray>, Color)> {
        let mut scatter_dir = hr.normal + Vec3::random_unit_vector();

        if scatter_dir.near_zero() {
            scatter_dir = hr.normal;
        }

        let scattered = Ray::new(hr.p, scatter_dir);
        let attenuation = self.albedo;
        Some((Some(scattered), attenuation))
    }
}

#[derive(Clone, Copy)]
pub struct Metal {
    albedo: Color,
}

impl Metal {
    pub fn new(albedo: Color) -> Self {
        Metal { albedo }
    }
}

impl Scatter for Metal {
    fn scatter(&self, r_in: &Ray, hr: &HitRecord) -> Option<(Option<Ray>, Color)> {
        let reflected = Vec3::reflect(&r_in.direction, &hr.normal);
        let scattered = Ray::new(hr.p, reflected);
        let attenuation = self.albedo;

        if Vec3::dot(&scattered.direction, &hr.normal) > 0.0 {
            Some((Some(scattered), attenuation))
        } else {
            None
        }
    }
}
