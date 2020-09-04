wall=1.5;
wall1=0.6;
tol=0.2;
dmain=38;
dlug=9;
axis=1.5;
axismain=dmain-2*wall-1.5;
echo("axismain",axismain);
d1axis=dmain-2*wall-6;
d2axis=dmain-2*wall-2;
d1oaxis=dmain-2*wall-13;
d2oaxis=dmain-2*wall-10;
z3axis=dmain-2*wall-8;
d3axis=1.5; // 3mm service axis
hbase=15;
hstick=10;
dstick=6;
mntwidth1=22-tol;
mntwidth2=19-tol;

module z(offs) translate([0,0,offs]) children();
module rz(angle) rotate([0,0,angle]) children();
module ry(angle) rotate([0,angle,0]) children();
module rx(angle) rotate([angle,0,0]) children();

module capxy()
{
    module f0() for(r=[0,90])rz(r)rx(90)
        cylinder(d=axis,h=dmain,center=true,$fn=23);
    module f1() difference() {
            union() {
                sphere(d=dmain,$fn=91); 
                z(dmain/2-wall-wall)cylinder(d1=dstick*3,d2=dstick,h=dstick,$fn=41);
                z(dmain/2-wall)cylinder(d=dstick,h=hstick+wall,$fn=41);
                }
            sphere(d=dmain-2*wall,$fn=91);
            z(-dmain/2)cube([dmain,dmain,dmain],center=true);
            f0();
        }
    module f2() difference() {
        intersection() {
            for(r=[0:90:359])rz(r)rx(90)
                z(axismain/2)cylinder(d=dlug,h=wall+1.5,$fn=23);
            sphere(d=dmain,$fn=91); 
        }
        f0();
    }
    f1();
    f2();
}

module drivex(pot=false)
{
    o=d1axis/2-wall;
    module f0() {
        for(r=[0,90])rz(r)rx(90)
            cylinder(d=axis,h=dmain,center=true,$fn=23);
        if(pot)rx(90)rotary6(tol=tol/2,hh=dmain/2);
        }
    module f1() {
        intersection() {
            rotate_extrude(convexity=4,$fn=81)
                translate([o,-dlug/2]) square([wall,dlug]);
            sphere(d=d1axis,$fn=81);
        }
        for(t=[90,-90])ry(t)
          z(o)cylinder(d=dlug,h=(axismain-tol)/2-o,$fn=23);
    }
    module f2() for(r=[0,180])rz(r)rx(90)
        z(d1oaxis/2)cylinder(d=dlug,h=o-d1oaxis/2,$fn=23);
    difference() { f1(); f0(); }
    difference() { f2(); f0(); }
}

module drivey_svc()
{
    o1=d2axis/2-wall;
    h1=(axismain-tol)/2-o1;
    h3=(d2axis-z3axis)/2-wall;
    module f0() for(r=[0,90])rz(r)rx(90)
        cylinder(d=axis,h=dmain,center=true,$fn=23);
    module f1() {
        intersection() {
            ry(90)rz(90)rotate_extrude(angle=180,convexity=4,$fn=81)
                translate([o1,-dlug/2])square([wall,dlug]);
            sphere(d=d2axis,$fn=81);
        }
        for(r=[0,180])rz(r)rx(90)z(o1)cylinder(d=dlug,h=h1);
    }
    module f2() z(z3axis/2) 
        cylinder(d=dlug,h=h3);
    module f3()
        cylinder(d=d3axis,h=dmain,center=true,$fn=29);
    difference() { f1(); f0(); f3(); }
    difference() { f2(); f3(); }
}


module drivey(pot=false)
{
    o1=d2oaxis/2-wall;
    h4=(z3axis-tol)/2-o1;
    module f0() {
        for(r=[0,90])rz(r)rx(90)
            cylinder(d=axis,h=dmain,center=true,$fn=23);
        if(pot)ry(90)rz(90)rotary6(tol=tol/2,hh=dmain/2);
    }
    module f1() {
        rx(90)rotate_extrude(angle=180,convexity=4,$fn=81)
            translate([o1,-dlug/2])square([wall,dlug]);
        for(r=[90,270])rz(r)rx(90)z(o1-wall)cylinder(d=dlug,h=wall*2);
    }
    module f1a() sphere(d=d2oaxis,$fn=81);
    module f2() z(o1)  
        cylinder(d=dlug,h=h4);
    module f3()
        cylinder(d=d3axis,h=dmain,center=true,$fn=29);
    difference() { intersection() {f1();f1a();} f0(); f3(); }
    difference() { f2(); f3(); }
}

module mntstand()
{
    module f1a()
        z(-hbase)cube([wall,wall,hbase]);
    module f1b()
        z(-hbase)cube([dlug/1,wall,wall]);
    // stand support
    translate([0,-dlug/2])hull(){f1a(); f1b();}
    translate([0,dlug/2-wall])hull(){f1a(); f1b();}
    // stand wall
    hull() { translate([0,-dlug/2])f1a();
    translate([0,dlug/2-wall])f1a(); }
    // stand pivot center
    ry(90)cylinder(d1=dlug,d2=dlug/2,h=wall*2);
}

module mntpotstand()
{
    potdia=6.5+tol; // central rod for case size
    potw=10; // pot width
    poth=6.5; // pot bottom to axis size
    potz=5.2; // axial size
    potpins=3.5;
    
    h1=potw;
    w1=wall1+wall+potz;
    module f1a()
        translate([0,-h1/2,-poth-wall])
        cube([w1,wall,wall]);
    module f1b()
        translate([wall1+potz,-(h1-2*wall+.1)/2,-poth-wall])
        cube([wall,h1-2*wall+.1,wall]);
    module f1t()
        translate([wall*2,0,-hbase+poth+wall])children();
    module f1 ()
        hull() for(t=[0,1])mirror([0,t,0])f1a();
    module f2 () {
        for(t=[0,1])mirror([0,t,0])
            hull() { f1a(); f1t() f1a(); }
        hull() { f1b(); f1t() f1b(); }
    }
    module f3() 
        hull() { f1b(); z(poth)f1b(); }
    module f4() difference() {
        translate([0,-h1/2,-poth-wall])
            cube([wall1,h1,poth+wall]);
        ry(90)z(-.01)
            cylinder(d=potdia,h=potz+2*wall,$fn=31);
    }
    module f5()
      for(k=[-1,0,1]) translate([potpins+wall1,k*2.5,-poth-wall-.1])
          cylinder(d=1,h=wall*2,$fn=19);

    difference() { f1(); f5(); }
    f2();
    f3();
    f4();
}

module mntbase0()
{
    module f0() for(r=[0,90])rz(r)rx(90)
        cylinder(d=axis,h=dmain,center=true,$fn=23);
    module f2() {
        for(t=[90,270])rz(t)translate([-mntwidth1/2,0]) mntstand();
        for(t=[0,180])rz(t)translate([-mntwidth2/2,0]) mntstand();
        z(-hbase+wall/2) cylinder(d=dmain,h=wall,center=true);
    }
    difference() { f2(); f0(); }
}

module mntbase()
{
    module f0() for(r=[0,90])rz(r)rx(90)
        cylinder(d=axis,h=dmain,center=true,$fn=23);
    module f2() {
        rz(-90)translate([-mntwidth1/2,0]) mntstand();
        translate([-mntwidth2/2,0]) mntstand();
        rz(90)translate([-mntwidth1/2,0]) mntpotstand();
        rz(180)translate([-mntwidth2/2,0]) mntpotstand();
        z(-hbase+wall/2) cylinder(d=dmain,h=wall,center=true);
    }
    difference() { f2(); f0(); }
}

module rotary6(tol=0,hh=6.5) let(flatspot=1.5)
intersection() {
    cylinder(d=6+tol,h=hh,$fn=32);
    translate([0,-flatspot])cube([6+tol,6+tol,hh*3],center=true);
}

module rv09()
{
    cylinder(d=6.5,h=0.5,$fn=30); // rod ring
    color([.2,.2,.2]) rotary6(hh=4.0); // axias rod
    translate([-9.8/2,-6.5,-5])cube([9.8,12,5]); // body
    translate([0,-6.5,-3.5]) // connection pin
    for(x=[-2.5,0,2.5]) translate([x,0,0])
        rx(90) cylinder(d=.5,h=3.5);
}


//capxy();
drivex(true);
//drivey_svc();
drivey(true);
//mntbase0();
mntbase();
rx(90)z(10.2)rv09();
rz(90)rx(90)z(8.7)rv09();


module dexpmnt() {
    z(-18)cylinder(d=38,h=18,$fn=81);
    z(-5) for(x=[-.5,.5],y=[-.5,.5])translate([x,y]*30) 
        cylinder(d=1.5,h=5,$fn=15);
    module dx(x) let(sz=40,d=199)
        translate([x,0]*sz/2)translate([-x*d/2,0])cylinder(d=d,h=2,$fn=200);
    intersection() { dx(-1); dx(+1); rz(90) dx(-1); rz(90) dx(1);} 
        
}

//z(3)#dexpmnt();
