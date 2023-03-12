use std::ops::{Add, Mul};

#[derive(Debug)]
struct vec3 {
    x: f32,
    y: f32,
    z: f32,
}

impl vec3 {
    fn new(x, y, z) -> Self {
        vec3{x, y, z}
    }
}

impl<'a, 'b> Add<&'b vec3> for &'a vec3 {
    type Output = vec3;

    fn add(self, other: &'b vec3) -> vec3 {
        vec3 {
            x: self.x + other.x,
            y: self.y + other.y,
            z: self.z + other.z,
        }
    }
}

impl<'a, 'b> Mul<&'b vec3> for &'a vec3 {
    type Output = vec3;

    fn mul(self, other: &'b vec3) -> vec3 {
        vec3 {
            x: self.x * other.x,
            y: self.y * other.y,
            z: self.z * other.z,
        }
    }
}

fn test_ppm(image_width: i32, image_height: i32) {
    println!("P3\n{} {}\n255", image_width, image_height);

    for j in (0..image_height).rev() {
        for i in 0..image_width {
            let r = (i as f64) / ((image_width - 1) as f64);
            let g = (j as f64) / ((image_height - 1) as f64);
            let b = 0.25;

            let ir = (255.999 * r) as i32;
            let ig = (255.999 * g) as i32;
            let ib = (255.999 * b) as i32;

            println!("{} {} {}", ir, ig, ib);
        }
    }
}

fn main() {
    // Image
    let aspect_ratio = 16.0 / 9.0;
    let image_width = 400;
    let image_height = ((image_width as f32) / aspect_ratio) as i32;

    // Camera

    let viewport_height = 2.0;
    let viewport_width = aspect_ratio * viewport_height;
    let focal_length = 1.0;

    let origin = point3(0, 0, 0);
    let horizontal = vec3::new(viewport_width, 0, 0);
    let vertical = vec3::new(0, viewport_height, 0);
    let lower_left_corner = origin - horizontal / 2 - vertical / 2 - vec3::new(0, 0, focal_length);

    // Render
    test_ppm(256 * 2, 256 * 3);
}
