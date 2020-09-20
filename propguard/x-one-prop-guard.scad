
//projection(cut=true)
//rotate([0,0,0])
*rotate([0,90,0])
translate([-30.5973,0,70])
import(file="X-One_V9.stl");

*translate([0,0,22])
color([1,1,1,1]*.5) hull() {
    cylinder(d=5*25.4,h=2,center=true);
    cylinder(d=16,h=7,center=true);
}
    
use <../model-airfoil/Naca4.scad>;
a=12;
r=70;
overhead=2;
h0=41;
h=h0/cos(a);
h2=15.7;lift=1;
hc=6.5;
dd=38;
w=3.5;
$fs=0.1;
$fa=4;

module outer()
//rotate([0,0,90])
rotate_extrude($fn=200) translate([-r,0]) intersection() {
    rotate([0,0,a]) translate([0,h]) rotate([0,0,-90])
        polygon(points=airfoil_data(
//            naca = [.1,.21,.055],
            naca = [.1,.21,.1355],
            L = h+overhead,
            N=100, 
            open = true));
    translate([-h/2,0])square([h,h]);
    }

module inner() {
for(p=[0:90:359])
rotate([0,90,p])
linear_extrude(r)
translate([-h2-lift,0])
polygon(points=airfoil_data(naca = [.0,.5,.15], L = h2, N=40, open = false));
}

module drill() {
    for(f=[0:90:359]) rotate([0,0,f]) hull() 
      for(k=[6,14])
        translate([k,0])cylinder(d=4,h=hc*3,center=true);
    cylinder(d=5,h=hc*3,center=true);
}

module guard()
difference() {
    union() {
        outer();
        inner();
        cylinder(d=dd,h=17);
    }
    translate([0,0,hc])cylinder(d=dd-3.5,h=17-hc+.01);
    translate([w,w,hc])cube([dd/2,dd/2,h2]);
    drill();
}

module supp2t()
{
    for(e=[0:45:359])rotate([0,0,e-15])
        translate([r-r/100,0,0]) difference() {
            cylinder(d=25,h=.5);
            cube([4,20,3],center=true);
        }
}

module i() intersection() { children(); cube([200,200,200]); }
//i()
guard(); 
supp2t();


