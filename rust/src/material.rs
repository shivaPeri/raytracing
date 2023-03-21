use crate::vec3::{Vec3, Point3, Color}
use crate::ray::{Ray, HitRecord}

// returns scattered ray (if its exists) and attenuation
pub trait Scatter {
	fn scatter(&self, r_in: &Ray, hr: &HitRecord) -> Option<(Option<Ray>, Color)>
}

pub enum Material {
	Lambertian(Lambertian),
	Metal(Metal),
}

impl Lambertian {
	pub fn new(albedo: Color) -> Self {
		Lambertian{ albedo }
	}
}

impl Scatter for Lambertian {
	fn scatter(r_in &Ray, hr: &HitRecord) -> Option<(Option<Ray>, Color)> {

		let mut scatter_dir = hr.normal + Vec3::random_unit_vector();

		if scatter_dir.near_zero() {
			scatter_dir = hr.normal;
		}

		scattered = Ray::new(hr.p, scatter_dir);
		attenuation = self.albedo;
		Some(Some(scattered), attenuation)
	}
}

impl Metal {
	pub fn new(albedo: Color) -> Self {
		Metal{ albedo }
	}
}

impl Scatter for Metal {
	fn scatter(r_in &Ray, hr: &HitRecord) -> Option<(Option<Ray>, Color)> {

		let reflected = Vec3::reflect(r_in.direction, hr.normal);
		scattered = Ray::new(hr.p, reflected);
		attenuation = self.albedo;

		if Vec3::dot(scattered.direction, hr.normal) > 0.0 {
			Some(Some(scattered), attenuation)
		} else {
			None
		}
	}
}