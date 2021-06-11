wall=1.5; // main wall thinkness
wall1=0.8; // thin wall thinkness
gap=0.75; // moving part gap
tol=0.2; // non-moving part setup tolerance

ELIPSO=true; // ellipsoidal drive arms

dmain=38; // 38 general outer cap size
dlug=9; // moving lug diameter
axis=1.5; // axis shaft diameter
d3axis=1.5; // 3mm service axis
hub=2.5; // 2*wall potetiometer hub size

axismain=dmain-2*wall-1.4; // 1.5 main cap inter lug size
d1axis=axismain-2*wall-1.4;  // Yaxis arm outer (sweep X)
d2axis=axismain-.5; // Xservice arm outer
z3axis=d2axis-3*wall; // Xservice upper axis
d2oaxis=dmain-2*wall-10+(ELIPSO?3.5:0); // Xaxis-pot

mntwidthY=d1axis-hub*2; // Ypot axis (output) x-size
mntwidthX=d2oaxis-hub*2;// Xpot axis (output) y-size

dstick=6;  // handle stick diameter
hbase=15;  // handle stick base cone
hstick=10; // handle stick length


*echo("axismain",axismain);
echo("mntwidthY",mntwidthY);
echo("mntwidthX",mntwidthX);
*let(a=axismain) %cube([a,a,a],center=true);

//23456789012345678901234567890123456789012345678901234567890123

module z(offs) translate([0,0,offs]) children();
module rz(angle) rotate([0,0,angle]) children();
module ry(angle) rotate([0,angle,0]) children();
module rx(angle) rotate([angle,0,0]) children();

module capxy()
{
    module f0() for(r=[0,90])rz(r)rx(90)
        cylinder(d=axis,h=dmain,center=true,$fn=23);
    module handle(d=dstick,h=hstick) {
        z(-2*wall)cylinder(d1=d*3,d2=d,h=dstick,$fn=41);
        z(-wall)cylinder(d=d,h=h+wall,$fn=41);
    }
    module cap() difference() {
        union() { sphere(d=dmain,$fn=91); z(dmain/2) handle(); }
        sphere(d=dmain-2*wall,$fn=91); //inner
        z(-dmain/2)cube([dmain,dmain,dmain],center=true);//half
        f0();
    }
    module cap_lugs() intersection() {
        for(r=[0:90:359])rz(r)rx(90)
            z(axismain/2)cylinder(d=dlug,h=wall+1.5,$fn=23);
        sphere(d=dmain,$fn=91); 
    }
    cap();
    difference() { cap_lugs(); f0(); }
}

module drive_arc(do,a=360) intersection() {
    rotate_extrude(angle=a,convexity=4,$fn=81)
        translate([do/2-wall,-dlug/2]) square([wall,dlug]);
    sphere(d=do,$fn=81);
}

module drivey(pot=false)
{
    s=ELIPSO?d2axis/d1axis:1;
    hL=ELIPSO?wall:wall*2+.1;
    module f0() {
        for(r=[0,90])rz(r)rx(90)
            cylinder(d=axis, h=dmain, center=true, $fn=23);
        if(pot)rx(90)rotary6(tol=tol/2, hh=dmain/2);
    }
    module outer_lug()
        for(t=[90,-90]) ry(t) z(-(axismain-tol)/2)
            cylinder(d=dlug, h=hL,$fn=23);
    module inner_xlug() for(r=[0,180]) rz(r) rx(90)
        z(mntwidthY/2) cylinder(d=dlug, h=hub-wall+.1, $fn=23);

    difference() { scale([s,1])drive_arc(d1axis); f0(); }
    difference() { outer_lug(); f0(); }
    difference() { inner_xlug(); f0(); }
}

module drivex_svc()
{
    module f0() for(r=[0,90])rz(r)rx(90)
        cylinder(d=axis,h=dmain,center=true,$fn=23);
    module f1()
        cylinder(d=d3axis,h=dmain,center=true,$fn=29);
    module outer_lug()
        for(r=[90,-90]) rx(r) z(-(axismain-tol)/2)
            cylinder(d=dlug, h=(axismain-d2axis-tol)/2+wall);
    module upper_lug() z(z3axis/2) 
        cylinder(d=dlug, h=(d2axis-z3axis)/2-wall+.1);

    difference() {rz(90)rx(90)drive_arc(d2axis,180); f0();f1();}
    difference() { outer_lug(); f0(); }
    difference() { upper_lug(); f1(); }
}

module drivex(pot=false)
{
    hZ=(z3axis-d2oaxis)/2;
    module f0() {
        for(r=[0,90])rz(r)rx(90)
            cylinder(d=axis,h=dmain,center=true,$fn=23);
        if(pot)ry(-90)rz(-90)rotary6(tol=tol/2,hh=dmain/2);
    }
    module f3()
        cylinder(d=d3axis,h=dmain,center=true,$fn=29);
    module inner_ylug() intersection() {
        sphere(d=d2oaxis,$fn=81);
        for(r=[90,270]) rz(r)rx(90) z(mntwidthX/2)
            cylinder(d=dlug, h=hub);
    }
    module upper_lug() {
        z(d2oaxis/2-wall-wall/2)
            cylinder(d=dlug,h=wall/2+.1); // base
        ry(180) z(-(z3axis-tol)/2)
            cylinder(d1=dlug/2,d2=dlug,h=hZ+wall/2); // driver
    }
    difference() { rx(90)drive_arc(d2oaxis,180); f0(); f3(); }
    difference() { upper_lug(); f3(); }
    difference() { inner_ylug(); f0(); }
}

module mntstand()
{
    poth=6.5; // pot bottom to axis size
    dis=wall*2-wall;
    dl=dlug;
    module f1a() // vertical element
        z(-hbase)cube([wall,wall,hbase]);
    module f1b() // laydown element
        z(-hbase)cube([dl/1,wall,wall]);
    // stand support
    translate([wall,-dl/2])hull(){f1a(); f1b();}
    translate([wall,dl/2-wall])hull(){f1a(); f1b();}
    // stand wall
    hull() { translate([wall,-dl/2])f1a();
    translate([wall,dl/2-wall])f1a(); }
    // stand pivot center
    ry(90)cylinder(d2=dl,d1=dl-2*wall,h=wall,$fn=36);
    ry(90)z(wall-.01)cylinder(d=dl,h=wall+.01,$fn=36);
}

module mntpotstand()
{
    poth=6.5; // pot bottom to axis size
    potdia=7+tol/2; // central rod for case size
    potw=10.2; // pot width
    potz=6; // axial size
    potpins=4;
    
    h1=potw-2;
    w1=wall1+wall+potz;
    module f1a() // depth liner
        translate([0,-h1/2,-poth-wall])
        cube([w1,wall,wall]);
    module f1b() // back liner
        translate([wall1+potz,-(h1-2*wall+.1)/2,-poth-wall])
        cube([wall,h1-2*wall+.1,wall]);
    module f1t() // slant offset
        translate([wall*2,0,-hbase+poth+wall])children();
    module f1 () // bottom
        hull() for(t=[0,1])mirror([0,t,0])f1a();
    module f2 () { // slant standing
        for(t=[0,1])mirror([0,t,0]) // sides
            hull() { f1a(); f1t() f1a(); }
        hull() { f1b(); f1t() f1b(); } // back
    }
    module back() 
        hull() { f1b(); z(poth)f1b(); }
    module front()
        translate([0,-h1/2,-poth-wall])
            cube([wall1,h1,poth+wall]);
    module drills()
      for(k=[-1,0,1])translate([potpins+wall1,k*2.5,-poth-wall-.1])
          cylinder(d=1.6,h=wall*2,$fn=19);

    difference() { f1(); drills(); }
    //f2();
    back();
    front();
}

module mntbase0()
{
    module f0() for(r=[0,90])rz(r)rx(90)
        cylinder(d=axis,h=dmain,center=true,$fn=23);
    module f2() {
        // Ypot axis
        rz(90)translate([-(mntwidthY-tol)/2,0]) mntstand();
        rz(-90)translate([-(mntwidthY-tol)/2,0]) mntstand();
        // Xpot axis
        translate([-(mntwidthX-tol)/2,0]) mntstand();
        rz(180)translate([-(mntwidthX-tol)/2,0]) mntstand();
    }
    difference() { f2(); f0(); }
    z(-hbase) cylinder(d=dmain,h=wall);
}

module mntbase()
{
    potoffset=mntwidthY/2-5;
    potdia=7+tol/2;
    module f0() for(r=[0,90])rz(r)rx(90) {
        cylinder(d=axis,h=dmain,center=true,$fn=23);
        ry(-90) z(potoffset)
            cylinder(d=potdia,h=5*2,$fn=31);
    }
    module f2() {
        // Y-pot
        rz(-90)translate([-(mntwidthY-tol)/2,0]) mntstand();
        rz(90)translate([-(mntwidthY-tol)/2,0]) mntpotstand();
        // X-pot
        rz(180)translate([-(mntwidthX-tol)/2,0]) mntstand();
        translate([-(mntwidthX-tol)/2,0]) mntpotstand();
        z(-hbase+wall/2) cylinder(d=dmain,h=wall,center=true);
    }
    difference() { f2(); f0(); }
}

module rotary6(tol=0,hh=6.5) let(flatspot=1.5)
intersection() {
    cylinder(d=6+tol,h=hh,$fn=32);
    translate([0,-flatspot])
        cube([6+tol,6+tol,hh*3],center=true);
}

module rv09(angle=0)
{
    sl=5.0; // shaft len
    rd=7; rh=0.8; // shaft ring
    w=10.2; h=12.1; d=6; // pot dimension
    o=6.5; //6.5 from bottom
    pins=4.0; // 4.0 form face
    
    color([.2,.2,.2])rz(angle)rotary6(hh=sl); // axias rod
    color([.5,.5,.5])
    cylinder(d=rd,h=rh,$fn=30); // shaft ring
    color([.5,.5,.5])
    translate(-[w/2,o,d])cube([w,h,d]); // body
    color([.7,.7,.7])translate([0,-o,-pins]) // connection pins
    for(x=[-2.5,0,2.5]) translate([x,0,0]) {
        cube([1.5,3*2,0.4],center=true);
        rx(90) cylinder(d=.5,h=7.5*2,center=true,$fn=6);
    }
}

module assembly0()
{
//capxy();
//drivey();
//drivex_svc();
//drivex();
mntbase0();
}

module assembly()
{
rot1=0;
rot2=0;
//ry(rot1)rx(rot2)
//capxy();
ry(rot1)
drivey(true);
//rx(rot2) ry(rot1/2)
//    drivex_svc();
rx(rot2)
drivex(true);
mntbase();
//rx(90)       z(mntwidthY/2-wall1-tol)rv09(-rot1);
//rz(-90)rx(90)z(mntwidthX/2-wall1-tol)rv09(rot2);
}

module dexpmnt()
{
    module dx(x) let(sz=40,d=199)
      translate([-x*d/2,0]+[x,0]*sz/2)cylinder(d=d,h=2,$fn=200);

    intersection() {
        dx(-1); dx(+1); rz(90) dx(-1); rz(90) dx(1);} 
    z(-18) cylinder(d=38,h=18,$fn=81);
    z(-5) for(x=[-.5,.5],y=[-.5,.5]) translate([x,y]*30) 
        cylinder(d=1.5,h=5,$fn=15);
}

assembly0();
//assembly();

//#z(3) dexpmnt();
