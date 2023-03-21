use rand::Rng;
use std::ops::{Add,Sub,Mul,Div,Neg}



#[derive(Debug, Clone, Copy)]
struct Vec3([f32; 3]);
use Vec3 as Point3;
use Vec3 as Color;

impl Vec3{
    pub fn new() -> Self {
        Vec3([0,0,0])
    }

    // Accessor methods
    pub fn x(&self) -> f32 {
        self[0]
    }
    
    pub fn y(&self) -> f32 {
        self[1]
    }
    
    pub fn z(&self) -> f32 {
        self[2]
    }

    pub fn length(&self) -> f32 {
        self.length_squared().sqrt()
    }

    pub fn length_squared(&self) -> f32 {
        self.[0]*self[0] + self[1]*self[1] + self[2]*self[2]
    }

    // other methods
    pub fn dot(&self, other: &Vec3) -> f32 {
        self.x() * other.x() + self.y() * other.y() + self.z() * other.z()
    }
    
    pub fn cross(&self, other: &Vec3) -> Vec3 {
        Vec3{[
            self.y() * other.z() - self.z() * other.y(),
            self.z() * other.x() - self.x() * other.z(),
            self.x() * other.y() - self.y() * other.x()
        ]}
    }
    
    pub fn unit_vector(&self) -> Vec3 {
        let length = self.length();
        Vec3{[ self.x() / length, self.y() / length, self.z() / length ]}
    }

    // pub fn normalize(&self) -> Vec3 {
        
    // }
    
    pub fn near_zero(&self) -> bool {
        false   
    }
}

impl Add for Vec3 {
    type Output = Self;

    fn add(self, other: Self) -> Self {
        Self{[
            self.x() + other.x(),
            self.y() + other.y(),
            self.z() + other.z()
        ]}
    }     
}

impl Sub for Vec3 {
    type Output = Self;

    fn sub(self, other: Self) -> Self {
        Self{[
            self.x() - other.x(),
            self.y() - other.y(),
            self.z() - other.z()
        ]}
    }     
}

impl Neg for Vec3 {
    type Output = Self;

    fn neg(self, other: Self) -> Self {
        Self{[
            -self.x(),
            -self.y(),
            -self.z()
        ]}
    }     
}

impl Mul<f64> for Vec3 {
    type Output = Self;

    fn mul(self, other: f64) -> Self {
        Self{[
            self.x() * other,
            self.y() * other,
            self.z() * other,
        ]}
    }
}