use crate::ray::{HitRecord, Ray};
use crate::vec3::{Color, Vec3};
use num_traits::Pow;
use rand::Rng;

// returns scattered ray (if its exists) and attenuation
pub trait Scatter {
    fn scatter(&self, r_in: &Ray, hr: &HitRecord) -> Option<(Option<Ray>, Color)>;
}

#[derive(Clone, Copy)]
pub enum Material {
    Lambertian(Lambertian),
    Metal(Metal),
    Dielectric(Dielectric),
}

impl Scatter for Material {
    fn scatter(&self, r_in: &Ray, hr: &HitRecord) -> Option<(Option<Ray>, Color)> {
        match self {
            Material::Lambertian(x) => x.scatter(r_in, hr),
            Material::Metal(x) => x.scatter(r_in, hr),
            Material::Dielectric(x) => x.scatter(r_in, hr),
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
    fn scatter(&self, _r_in: &Ray, hr: &HitRecord) -> Option<(Option<Ray>, Color)> {
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
    fuzz: f32,
}

impl Metal {
    pub fn new(albedo: Color, fuzz: f32) -> Self {
        Metal { albedo, fuzz }
    }
}

impl Scatter for Metal {
    fn scatter(&self, r_in: &Ray, hr: &HitRecord) -> Option<(Option<Ray>, Color)> {
        let reflected = Vec3::reflect(&r_in.direction, &hr.normal);
        let scattered = Ray::new(hr.p, reflected + self.fuzz * Vec3::random_in_unit_sphere());
        let attenuation = self.albedo;

        if Vec3::dot(&scattered.direction, &hr.normal) > 0.0 {
            Some((Some(scattered), attenuation))
        } else {
            None
        }
    }
}

#[derive(Default, Clone, Copy)]
pub struct Dielectric {
    pub ir: f32,
}

fn random() -> f32 {
    let mut rng = rand::thread_rng();
    return rng.gen_range(0.0..1.0);
}

// Schlick's approximation
fn reflectance(cosine: f32, ref_idx: f32) -> f32 {
    let r0 = ((1.0 - ref_idx) / (1.0 + ref_idx)).powf(2.0);
    return r0 + (1.0 - r0) * (1.0 - cosine).powf(5.0);
}

impl Scatter for Dielectric {
    fn scatter(&self, r_in: &Ray, hr: &HitRecord) -> Option<(Option<Ray>, Color)> {
        let attenuation = Color::new(1.0, 1.0, 1.0);
        let refraction_ratio = if hr.front_face {
            1.0 / self.ir
        } else {
            self.ir
        };
        let unit_dir = r_in.direction.unit_vector();
        let cos_theta = Vec3::dot(&(-unit_dir), &hr.normal).min(1.0);
        let sin_theta = (1.0 - cos_theta * cos_theta).sqrt();

        let cannot_refract = refraction_ratio * sin_theta > 1.0;
        let mut direction = Vec3::zero();

        if cannot_refract || reflectance(cos_theta, refraction_ratio) > random() {
            direction = Vec3::reflect(&unit_dir, &hr.normal);
        } else {
            direction = Vec3::refract(&unit_dir, &hr.normal, refraction_ratio);
        }

        let scattered = Ray::new(hr.p, direction);
        Some((Some(scattered), attenuation))
    }
}
