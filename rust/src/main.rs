use indicatif::ProgressBar;
use rand::Rng;
use raytracer::{
    camera::Camera,
    ray::{Hittable, HittableList, Ray},
    sphere::Sphere,
    vec3::{Color, Point3, Vec3},
};

fn ray_color(r: Ray, world: &HittableList<Sphere>, depth: u32) -> Color {
    if depth == 0 {
        return Color::zero();
    }

    match world.hit(&r, 0.0, f32::INFINITY) {
        Some(hr) => {
            let target: Point3 = hr.p + hr.normal + Vec3::random_in_unit_sphere();
            return 0.5 * ray_color(Ray::new(hr.p, target - hr.p), world, depth - 1);
        }
        None => {
            let unit_direction = r.direction.unit_vector();
            let t = 0.5 * (unit_direction.y + 1.0);
            return (1.0 - t) * Vec3::new(1., 1., 1.) + t * Vec3::new(0.5, 0.7, 1.);
        }
    }
}

fn main() {
    // Image
    const aspect_ratio: f32 = 16.0 / 9.0;
    const image_width: i32 = 400;
    const image_height: i32 = ((image_width as f32) / aspect_ratio) as i32;
    const samples_per_pixel: i32 = 100;
    const max_depth: u32 = 50;

    // World
    let mut world = HittableList::new();
    world.add(Sphere::new(Point3::new(0., 0., -1.), 0.5));
    world.add(Sphere::new(Point3::new(0., -100.5, -1.), 100.));

    // Camera
    let camera = Camera::new();

    // Render

    let mut rng = rand::thread_rng();
    let bar = ProgressBar::new((image_width * image_height) as u64);

    println!("P3\n{} {}\n255", image_width, image_height);

    for j in (0..image_height).rev() {
        for i in 0..image_width {
            let mut color = Color::zero();

            for _s in 0..samples_per_pixel {
                let u: f32 = ((i as f32) + rng.gen_range(0.0..1.0)) / ((image_width - 1) as f32);
                let v: f32 = ((j as f32) + rng.gen_range(0.0..1.0)) / ((image_height - 1) as f32);

                let r = camera.get_ray(u, v);
                color += ray_color(r, &world, max_depth);
            }

            color /= samples_per_pixel as f32;

            let ir: u8 = (255.999 * color.x) as u8;
            let ig: u8 = (255.999 * color.y) as u8;
            let ib: u8 = (255.999 * color.z) as u8;
            println!("{} {} {}", ir, ig, ib);
            bar.inc(1);
        }
    }
    bar.finish()
}
