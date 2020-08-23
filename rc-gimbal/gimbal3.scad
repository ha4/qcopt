wall=2.5;
module z(offs) translate([0,0,offs]) children();
module rz(angle) rotate([0,0,angle]) children();
module ry(angle) rotate([0,angle,0]) children();
module rx(angle) rotate([angle,0,0]) children();

module mntplate()
{
    module f1() {
        translate(-[52,52,wall*2]/2) cube([52,52,wall]);
        for(i=[0:90:359]) rz(i)
            translate([10,10,-wall]) cube([18.5,18.5,wall]);
    }
    module f2() {
        cylinder(d=50,h=3.5);
    }
    module f3() {
        x=5.5;
        y=3;
        difference() {
            cube([x,x,17]);
            // ref points
            translate([3.5,0,2.5])rx(90) cylinder(d=2,h=3,$fn=17,center=true);
            translate([0,3.5,5.5])ry(90) cylinder(d=2,h=3,$fn=17,center=true);
            // bolt ponts
            translate([3.5,0,9.5]) rx(90) cylinder(d=1.9,h=9,$fn=17,center=true);
            translate([0,3.5,13.5])ry(90) cylinder(d=1.9,h=9,$fn=17,center=true);
        }
        translate([x-.1,0,0]) cube([10.5-x+.1,wall,8]);
        translate([0,x,0])
        hull() for(i=[0,90]) rx(i)
        translate([0,0,-.1])cube([wall,y,.1]);
    }

    difference(){ f1(); cylinder(d=45,h=3*wall,center=true); }
    f2();
    for(i=[0:90:359]) rz(i)
        translate([52,52,-wall*2]/2)rotate([180,0,-90])
            f3();
}

module sideplate()
{
    wall1=1;
    bol=[[-52/2+3.5,-wall-9.5],[52/2-3.5,-wall-13.5]];
    module f1() z(-wall) {
        translate([-51/2,-17-2.5])cube([51,17,wall]);
        translate([-20/2,-wall-.5]) cube([20,wall+.5,wall]);
        translate([0,-14.5]) cylinder(d=8,h=7,$fn=31);
        translate([0,-12.5])for(j=[-45,45])rz(j)
        translate([-wall1/2,0])cube([wall1,12,7]);
        // refs
        translate([-52/2+3.5,-wall-2.5]) cylinder(d=2,h=wall+1,$fn=21);
        translate([52/2-3.5,-wall-5.5]) cylinder(d=2,h=wall+1,$fn=21);      
        // bolts
        for(j=bol) translate(j) cylinder(d=7,h=wall,$fn=21);
    }
    difference() {
        f1();
        translate([0,-14.5]) cylinder(d=4,h=7*3,center=true,$fn=31);
        for(j=bol) translate(j) {
            cylinder(d=2.2,h=wall*3,center=true,$fn=21);
            z(-2-wall+1)cylinder(d=4.6,h=2.01,$fn=21);
            z(-wall+1)cylinder(d1=4.6,d2=2.2,h=1,$fn=21);
        }
    }
}

module stickA()
{
    d1=1.5;
    d2=4;
    d3=3;
    asz=25;
    do=27;
    module xcylinder(d,h,center) {
        rotate_extrude(convexity=4) translate([d/2-wall,-h/2]) square([wall,h]);
    }
    module f1() {
        rx(90) cylinder(d=5,h=asz,center=true,$fn=31);
        translate([-7/2,-7/2,-2.5-0.3])cube([7,7,16.3]);
        cylinder(d=6,h=19-5/2,$fn=21);
        intersection() {
            rx(90)union(){
                xcylinder(d=do,h=7,center=true,$fn=67);
                cylinder(d=do,h=wall,center=true);
                }
            z(4.2)translate([-do/2,-7/2])cube([do,7,do]);
        }
    }
    difference() {
        f1();
        for(m=[-1,1])rx(m*90)z(25/2-5)cylinder(d=d1,h=6,$fn=13);
        z(-3)cylinder(d=d3,h=5,$fn=17);
        z(6)cylinder(d=d2,h=do,$fn=19);
    }
}

module stickB()
{
    asz=20;
}

stickA();

////mntplate();
///translate([0,52/2,0]) rx(90)sideplate();
//rz(-90)translate([0,52/2,0]) rx(90)sideplate();
