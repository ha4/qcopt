
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
    
use <Naca4.scad>;
a=12;
r=70;
overhead=2;
h0=41;
h=h0/cos(a);
h2=15.7;lift=1;
hc=6.5;
dd=38;
w=3.5; // wall big
tw=0.5; // thin wall
extra=1; // beam part extension
$fs=0.1;
$fa=4;

module outer(dw=0) intersection() {
    offset(delta=dw)
    rotate([0,0,a]) translate([0,h]) rotate([0,0,-90])
        polygon(points=airfoil_data(
//            naca = [.1,.21,.055],
            naca = [.1,.21,.1355],
            L = h+overhead,
            N=100, 
            open = true));
    translate([-h/2,0])square([h,h]);
    }

module inner(dw=0)
offset(delta=dw)
translate([-h2-lift,0])
polygon(points=airfoil_data(naca = [.0,.5,.15], L = h2, N=40, open = false));

module central(dw=0)
    cylinder(d=dd+dw,h=17);

module centercut() {
    translate([0,0,hc])cylinder(d=dd-3.5,h=17-hc+.01);
    translate([w,w,hc])cube([dd/2,dd/2,h2]);
}

module drill() {
    for(f=[0:90:359]) rotate([0,0,f]) hull() 
      for(k=[6,14])
        translate([k,0])cylinder(d=4,h=hc*3,center=true);
    cylinder(d=5,h=hc*3,center=true);
}

module reducewall(wall=tw) offset(delta=-wall)children();
module thinwall() difference(){children(); reducewall()children();}

module roundpart() rotate_extrude($fn=200)translate([-r,0])children();
module multi4()  for(p=[0:3]) rotate([0,0,p*90]) children();
module beampart() rotate([0,90,0]) translate([0,0,dd/2-extra]) linear_extrude(r+extra-dd/2)children();

module j_o(i,r=4) let(a=r-r*cos(i), b=r-r*sin(i))
    intersection() {
        roundpart() outer(b);
        beampart() inner(a);
     }
module j_i(i,r=4) let(a=r-r*cos(i), b=r-r*sin(i))
    intersection() {
        central(b);
        beampart() inner(a);
     }
module bevel_o() 
    for(i=[0:5:89]) hull() {j_o(i); j_o(i+5); }
module bevel_i() 
    for(i=[0:5:89]) hull() {j_i(i); j_i(i+5); }

//bevel_i();
//bevel_o();

//radialdiv();
//beamdiv();

module radialdiv(n=40)
    for(a=[0:360/n:359]) rotate([0,0,a])
    translate([r,0,h0/2]) cube([20,tw,h0+.5],center=true);

module beamdiv(n=13.1) let(sz=5,l=r+extra-dd/2,ofs=dd/2-extra){
    for(m=[0:l/n:l]) translate([ofs+m,0,h2/2+lift/2]) 
        cube([tw,sz,h2+lift],center=true);
    translate([ofs,-sz/2,h2/2]) cube([l,sz,tw]);
}

module guard() {
    difference() {
        union() {
            roundpart() outer();
            central();
            multi4() {
                beampart() inner();
                //bevel_o();  bevel_i();
            }
        }
        roundpart() reducewall() outer();
        multi4() beampart() reducewall() inner();
        centercut();
        drill();
    }
    intersection() {
        roundpart() outer();
        radialdiv();
    }
    multi4() intersection() {
        beampart() inner();
        beamdiv();
    }
}

module supp2t()
{
    for(e=[0:45:359])rotate([0,0,e-15])
        translate([r-r/100,0,0]) difference() {
            cylinder(d=25,h=.5);
            cube([4,20,3],center=true);
        }
}


///thinwall() inner();
//thinwall() outer();

module i() intersection() { children(); cube([200,200,200]); }

//i()
guard(); 
supp2t();


