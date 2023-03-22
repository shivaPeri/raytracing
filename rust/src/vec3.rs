use rand::Rng;
use std::ops::{Add, AddAssign, Div, DivAssign, Mul, Neg, Sub};

#[derive(Default, Clone, Copy)]
pub struct Vec3 {
    pub x: f32,
    pub y: f32,
    pub z: f32,
}

pub type Point3 = Vec3;
pub type Color = Vec3;

impl Vec3 {
    // creation methods
    pub fn new(x: f32, y: f32, z: f32) -> Self {
        Vec3 { x, y, z }
    }

    pub fn zero() -> Vec3 {
        Vec3 {
            x: 0.,
            y: 0.,
            z: 0.,
        }
    }

    pub fn random(min: f32, max: f32) -> Vec3 {
        let mut rng = rand::thread_rng();
        Vec3 {
            x: rng.gen_range(min..max),
            y: rng.gen_range(min..max),
            z: rng.gen_range(min..max),
        }
    }

    pub fn random_in_unit_sphere() -> Vec3 {
        loop {
            let p = Vec3::random(-1.0, 1.0);
            if p.length_squared() >= 1. {
                continue;
            }
            return p;
        }
    }

    pub fn random_in_unit_hemisphere(normal: &Vec3) -> Vec3 {
        let p = Vec3::random_in_unit_sphere();

        if Vec3::dot(&p, normal) > 0.0 {
            return p;
        } else {
            return -p;
        }
    }

    pub fn random_unit_vector() -> Vec3 {
        Vec3::random_in_unit_sphere().unit_vector()
    }

    // Property methods
    pub fn length(&self) -> f32 {
        self.length_squared().sqrt()
    }

    pub fn length_squared(&self) -> f32 {
        self.x * self.x + self.y * self.y + self.z * self.z
    }

    // calculation methods
    pub fn dot(a: &Vec3, b: &Vec3) -> f32 {
        a.x * b.x + a.y * b.y + a.z * b.z
    }

    pub fn cross(&self, other: &Vec3) -> Vec3 {
        Vec3 {
            x: self.y * other.z - self.z * other.y,
            y: self.z * other.x - self.x * other.z,
            z: self.x * other.y - self.y * other.x,
        }
    }

    pub fn unit_vector(&self) -> Vec3 {
        let length = self.length();
        Vec3 {
            x: self.x / length,
            y: self.y / length,
            z: self.z / length,
        }
    }

    pub fn normalize(&mut self) {
        let length = self.length();
        self.x /= length;
        self.y /= length;
        self.z /= length;
    }

    pub fn near_zero(&self) -> bool {
        let e = f32::EPSILON;
        self.x.abs() < e && self.y.abs() < e && self.z.abs() < e
    }

    pub fn reflect(v: &Vec3, n: &Vec3) -> Vec3 {
        return *v - 2.0 * Vec3::dot(v, n) * *n;
    }
}

impl Add for Vec3 {
    type Output = Self;

    fn add(self, other: Self) -> Self {
        Self {
            x: self.x + other.x,
            y: self.y + other.y,
            z: self.z + other.z,
        }
    }
}

impl AddAssign for Vec3 {
    fn add_assign(&mut self, other: Self) {
        *self = Self {
            x: self.x + other.x,
            y: self.y + other.y,
            z: self.z + other.z,
        };
    }
}

impl Sub for Vec3 {
    type Output = Self;

    fn sub(self, other: Self) -> Self {
        Self {
            x: self.x - other.x,
            y: self.y - other.y,
            z: self.z - other.z,
        }
    }
}

impl Neg for Vec3 {
    type Output = Self;

    fn neg(self) -> Self {
        Self {
            x: -self.x,
            y: -self.y,
            z: -self.z,
        }
    }
}

impl Mul<f32> for Vec3 {
    type Output = Self;

    fn mul(self, other: f32) -> Self {
        Self {
            x: self.x * other,
            y: self.y * other,
            z: self.z * other,
        }
    }
}

impl Mul<Vec3> for f32 {
    type Output = Vec3;

    fn mul(self, other: Vec3) -> Vec3 {
        Vec3 {
            x: self * other.x,
            y: self * other.y,
            z: self * other.z,
        }
    }
}

impl Mul<Vec3> for Vec3 {
    type Output = Self;

    fn mul(self, other: Vec3) -> Self {
        Self {
            x: self.x * other.x,
            y: self.y * other.y,
            z: self.z * other.z,
        }
    }
}

impl Div<f32> for Vec3 {
    type Output = Self;

    fn div(self, other: f32) -> Self {
        Self {
            x: self.x / other,
            y: self.y / other,
            z: self.z / other,
        }
    }
}

impl DivAssign<f32> for Vec3 {
    fn div_assign(&mut self, other: f32) {
        *self = Self {
            x: self.x / other,
            y: self.y / other,
            z: self.z / other,
        }
    }
}

impl Div<Vec3> for Vec3 {
    type Output = Self;

    fn div(self, other: Vec3) -> Self {
        Self {
            x: self.x / other.x,
            y: self.y / other.y,
            z: self.z / other.z,
        }
    }
}

///////////////////////////// TESTS

#[test]
fn test_new() {
    let p = Vec3 {
        x: 1.,
        y: 2.,
        z: 3.,
    };
    assert_eq!(p.x, 1.);
    assert_eq!(p.y, 2.);
    assert_eq!(p.z, 3.);

    let q = Vec3::new(1., 2., 3.);
    assert_eq!(q.x, 1.);
    assert_eq!(q.y, 2.);
    assert_eq!(q.z, 3.);
}

#[test]
fn test_zero() {
    let p = Point3::zero();
    assert_eq!(p.x, 0.);
    assert_eq!(p.y, 0.);
    assert_eq!(p.z, 0.);

    let c = Color::zero();
    assert_eq!(c.x, 0.);
    assert_eq!(c.y, 0.);
    assert_eq!(c.z, 0.);
}

#[test]
fn test_add_sub() {
    let a = Vec3::new(1., 2., 3.);
    let b = Vec3::new(3., 2., 1.);

    let c = a + b;
    assert_eq!(c.x, 4.);
    assert_eq!(c.y, 4.);
    assert_eq!(c.z, 4.);

    let c = a - b;
    assert_eq!(c.x, -2.);
    assert_eq!(c.y, 0.);
    assert_eq!(c.z, 2.);
}

#[test]
fn test_scalar_mult() {
    let a = Vec3::new(1.2, 2.1, 0.5);
    let b = 2.0 * a;
    let c = a * 2.0;

    assert_eq!(b.x, 2.4);
    assert_eq!(b.y, 4.2);
    assert_eq!(b.z, 1.0);

    assert_eq!(c.x, 2.4);
    assert_eq!(c.y, 4.2);
    assert_eq!(c.z, 1.0);
}

#[test]
fn test_scalar_div() {
    let a = Vec3::new(1.2, 2.1, 0.5);
    let b = a / 2.0;
    assert_eq!(b.x, 0.6);
    assert_eq!(b.y, 1.05);
    assert_eq!(b.z, 0.25);
}

#[test]
fn test_vec_mul() {
    let a = Vec3::new(1.2, 2.1, 0.5);
    let b = Vec3::new(10.0, 20.0, 30.0);
    let c = a * b;

    assert_eq!(c.x, 12.0);
    assert_eq!(c.y, 42.0);
    assert_eq!(c.z, 15.0);
}

#[test]
fn test_vec_div() {
    let a = Vec3::new(1.0, 2.1, 0.5);
    let b = Vec3::new(10.0, 20.0, 10.0);
    let c = a / b;

    assert_eq!(c.x, 0.1);
    assert_eq!(c.y, 0.105);
    assert_eq!(c.z, 0.05);
}
