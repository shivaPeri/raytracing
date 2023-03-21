use crate::vec3::{Point3, Vec3};

pub struct Ray {
    pub origin: Point3,
    pub direction: Vec3,
}

impl Ray {
    pub fn new(origin: Point3, direction: Vec3) -> Self {
        Ray { origin, direction }
    }

    pub fn at(&self, t: f32) -> Vec3 {
        return self.origin + t * self.direction;
    }
}

pub struct HitRecord {
    pub p: Point3,
    pub normal: Vec3,
    pub t: f32,
    pub front_face: bool,
}

impl HitRecord {
    pub fn set_face_normal(&mut self, r: &Ray, outward_normal: Vec3) {
        self.front_face = Vec3::dot(&r.direction, &outward_normal) < 0.0;
        self.normal = if self.front_face {
            outward_normal
        } else {
            -outward_normal
        };
        return;
    }
}

pub trait Hittable {
    fn hit(&self, ray: &Ray, t_min: f32, t_max: f32) -> Option<HitRecord>;
}

pub struct HittableList<T>
where
    T: Hittable,
{
    objects: Vec<T>,
}

impl<T: Hittable> HittableList<T> {
    pub fn new() -> Self {
        HittableList {
            objects: Vec::new(),
        }
    }

    pub fn add(&mut self, thing: T) {
        self.objects.push(thing);
    }
}

impl<T: Hittable> Hittable for HittableList<T> {
    fn hit(&self, ray: &Ray, t_min: f32, t_max: f32) -> Option<HitRecord> {
        let mut hit = None;
        let mut closest_so_far = t_max;

        for obj in self.objects.iter() {
            let tmp = obj.hit(ray, t_min, closest_so_far);
            match tmp {
                None => {}
                Some(hr) => {
                    closest_so_far = hr.t;
                    hit = Some(hr);
                }
            }
        }

        return hit;
    }
}
