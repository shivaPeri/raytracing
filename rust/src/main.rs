use indicatif::ProgressBar;
use rand::Rng;
use raytracer::{
    camera::Camera,
    material::{Dielectric, Lambertian, Material, Metal, Scatter},
    ray::{Hittable, HittableList, Ray},
    sphere::Sphere,
    vec3::{Color, Point3, Vec3},
};

fn ray_color(r: Ray, world: &HittableList<Sphere>, depth: u32) -> Color {
    if depth == 0 {
        return Color::zero();
    }

    match world.hit(&r, 0.0001, f32::INFINITY) {
        Some(hr) => {
            match hr.material.scatter(&r, &hr) {
                Some((Some(scattered), attenuation)) => {
                    attenuation * ray_color(scattered, world, depth - 1)
                }
                _ => Color::zero(),
            }

            // let target: Point3 = hr.p + hr.normal + Vec3::random_in_unit_sphere();
            // return 0.5 * ray_color(Ray::new(hr.p, target - hr.p), world, depth - 1);
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
    const ASPECT_RATIO: f32 = 16.0 / 9.0;
    const IMAGE_WIDTH: i32 = 400;
    const IMAGE_HEIGHT: i32 = ((IMAGE_WIDTH as f32) / ASPECT_RATIO) as i32;
    const SAMPLES: i32 = 100;
    const MAX_DEPTH: u32 = 50;

    // World

    let material_ground = Material::Lambertian(Lambertian::new(Color::new(0.8, 0.8, 0.0)));
    // let material_center = Material::Lambertian(Lambertian::new(Color::new(0.7, 0.3, 0.3)));
    // let material_left = Material::Metal(Metal::new(Color::new(0.8, 0.8, 0.8), 0.3));
    // let material_center = Material::Dielectric(Dielectric { ir: 1.5 });
    let material_center = Material::Lambertian(Lambertian::new(Color::new(0.1, 0.2, 0.5)));
    let material_left = Material::Dielectric(Dielectric { ir: 1.5 });
    let material_right = Material::Metal(Metal::new(Color::new(0.8, 0.6, 0.2), 0.0));

    let mut world = HittableList::new();
    world.add(Sphere::new(
        Point3::new(0.0, -100.5, -1.0),
        100.0,
        material_ground,
    ));
    world.add(Sphere::new(
        Point3::new(0.0, 0.0, -1.0),
        0.5,
        material_center,
    ));
    world.add(Sphere::new(
        Point3::new(-1.0, 0.0, -1.0),
        0.5,
        material_left,
    ));
    world.add(Sphere::new(
        Point3::new(-1.0, 0.0, -1.0),
        -0.4,
        material_left,
    ));
    world.add(Sphere::new(
        Point3::new(1.0, 0.0, -1.0),
        0.5,
        material_right,
    ));

    // Camera
    let lookfrom = Point3::new(3., 3., 2.);
    let lookat = Point3::new(0., 0., -1.);
    let vup = Vec3::new(0., 1., 0.);
    let dist_to_focus = (lookfrom - lookat).length();
    let aperture = 2.0;

    let camera = Camera::new(
        lookfrom,
        lookat,
        vup,
        20.0,
        ASPECT_RATIO,
        aperture,
        dist_to_focus,
    );

    // Render

    let mut rng = rand::thread_rng();
    let bar = ProgressBar::new((IMAGE_WIDTH * IMAGE_HEIGHT) as u64);

    println!("P3\n{} {}\n255", IMAGE_WIDTH, IMAGE_HEIGHT);

    for j in (0..IMAGE_HEIGHT).rev() {
        for i in 0..IMAGE_WIDTH {
            let mut color = Color::zero();

            for _s in 0..SAMPLES {
                let u: f32 = ((i as f32) + rng.gen_range(0.0..1.0)) / ((IMAGE_WIDTH - 1) as f32);
                let v: f32 = ((j as f32) + rng.gen_range(0.0..1.0)) / ((IMAGE_HEIGHT - 1) as f32);

                let r = camera.get_ray(u, v);
                color += ray_color(r, &world, MAX_DEPTH);
            }

            color /= SAMPLES as f32;

            let ir: u8 = (255.999 * color.x) as u8;
            let ig: u8 = (255.999 * color.y) as u8;
            let ib: u8 = (255.999 * color.z) as u8;
            println!("{} {} {}", ir, ig, ib);
            bar.inc(1);
        }
    }
    bar.finish()
}
