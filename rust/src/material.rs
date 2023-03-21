use crate::vec3::{Vec3, Point3, Color}
use crate::ray::{Ray, HitRecord}

pub trait Scatter {
	fn scatter(r_in: &Ray, attenuation: &mut Color, scattered: &mut Ray) -> Option<HitRecord>
}
