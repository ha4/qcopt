wall=2.5;
module z(offs) translate([0,0,offs]) children();
module rz(angle) rotate([0,0,angle]) children();
module ry(angle) rotate([0,angle,0]) children();
module rx(angle) rotate([angle,0,0]) children();

module mntplate()
{
    axial=14.5; // axle to top offset
    dbolt=2.2;// mount bolt drill
    mdim=45; // mount dimenstion
    xydim=52; // standings main dimension
    zdim=17; // standing height
    sx=5.5; // standing size
    sy=3; // diagonal stand support siz
    sz=5; // support standing size
    sh=8; // support height size
    bh=27; // braker stand height
    bz=4; // braker support size
    by1=10; // braker support offset
    bw=3;  // braker support wall
    bx=18; // braker-to-axis x-offset
    by=7;  // braker-to-axis y-offset
    cw=3.5; // cap wall
    cd=50;  // cap diameter
    wh=28.5; // stick window height
    ww=37.5; // stick window width
    ww1=27; // window drum width
    wh1=21; // window drum height
    wr=15; // window drum radius
    wdw=1; // drum window wall
    wz=7;  // window depth
    wa=28; // window angle
    module f1() { // base
        translate(-[xydim,xydim,wall*2]/2) cube([xydim,xydim,wall]);
        for(i=[0:90:359]) rz(i)
            translate([10,10,-wall]) cube([18.5,18.5,wall]);
    }
    module rsqr(sz,r) let(x=sz.x/2-r,y=sz.y/2-r) hull() for(i=[-x,x],j=[-y,y])
        translate([i,j]) circle(r=r,$fn=29);
    module rramp(sz1,sz2,r,h) let(s=[sz2.x/sz1.x,sz2.y/sz1.y])
        linear_extrude(convexity=5,height=h,scale=s)
            rsqr(sz1,r);
    module f2() { // cover
        cylinder(d=cd,h=cw);
        intersection() {
            cylinder(d=cd,h=cw*10,center=true);
            z(cw)rx(180)
                rramp([ww,wh]+[wall,wall]*2,[ww1,wh1]+[wall,wall]*2,2,wz);
        }
    }
    module f2i() { // cover cutout
        z(cw+.01)rx(180)
        rramp([ww,wh],[ww1,wh1]+[wall/2,-wall/2],2,wz+.03);
        z(-axial) ry(90)
        cylinder(r=wr-wdw,h=2*ww,center=true,$fn=43);
    }
    module f2a() {
        z(-axial)ry(90)difference() {
            cylinder(r=wr,h=ww-wall,center=true,$fn=43);
            cylinder(r=wr-wdw,h=ww*2,center=true,$fn=43);
            cylinder(r=wr+wdw,h=ww1,center=true,$fn=43);
            translate([wz-3.5+wr-axial,0,0])cube([wr*2,wr*2,ww+.1],center=true);
        }
    }
    module f3() { // standing
        y=3;
        difference() { // stand and drills
            z(-.01)cube([sx,sx,zdim]);
            // ref points
            translate([3.5,0,2.5])rx(90) cylinder(d=2,h=3,$fn=17,center=true);
            translate([0,3.5,5.5])ry(90) cylinder(d=2,h=3,$fn=17,center=true);
            // bolt ponts
            translate([3.5,0,9.5]) rx(90) cylinder(d=1.9,h=9,$fn=17,center=true);
            translate([0,3.5,13.5])ry(90) cylinder(d=1.9,h=9,$fn=17,center=true);
            let (xo=(xydim-mdim)/2)
            translate([xo,xo,-wall*4]) cylinder(d=dbolt,h=wall*5,$fn=13);
        }
        // stand square support
        translate([sx-.1,0,-.01]) cube([sz+.1,wall,sh]);
        // stand diagonal support
        translate([0,sx,0]) hull() for(i=[0,90]) rx(i)
        translate([0,0,-.1])cube([wall,sy,.1]);
    }
    module f4() { // extend stand support
        translate([0,sx-.1,-.01]) cube([wall,sz+.1,zdim]);
    }
    module f5() { // brake standing
        translate([sx-.1,0,-.01]) cube([bz+.1,wall,zdim]);
        translate([bz+sx-bw,0,0]) cube([bw,by,zdim]);
        translate([xydim/2-bx,by,0]) difference() {
            cylinder(d=4,h=bh,$fn=19);
            z(bh-5)cylinder(d=1.8,h=5+.1,$fn=13);
        }
    }
    module standmove()
        translate([xydim,xydim,-wall*2]/2)rotate([180,0,-90])
            children();

    difference(){
            f1();
            cylinder(d=45,h=3*wall,center=true);
            for(x=[-.5,.5],y=[-.5,.5]) translate([x*mdim,y*mdim,-wall*5])
                cylinder(d=dbolt,h=wall*7,$fn=13);
    }
    z(-0.01)difference() { f2(); f2i(); }
    f2a();
    for(i=[0:90:359]) rz(i) standmove() f3();
    rz(90) standmove() f4();
    rz(180) standmove() f5();
    
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
        z(-3)cylinder(d=d3,h=5,$fn=23);
        z(6)cylinder(d=d2,h=do,$fn=19);
    }
}

module stickB()
{
    d0=3; // axle diameter
    d1=7; // lug diameter
    d2=3; // sitick diameter
    d2h=2; // d2 groove depth
    asz=20.5; // axial size
    lext=1.25; // axle exterior size
    hsz=13; // total thing height
    ha=hsz-d1/2;// axial-bottom geight
    ih=6; // bottom height
    iw=4.5; // internal lug width
    msz=5; // bottom minimum size
    module f0() {
         ry(90)cylinder(d=d1-2,h=asz,center=true,$fn=30);
         ry(90)cylinder(d=d0,h=asz+2*lext,center=true,$fn=30);
   }
    module f1() hull() {
        ry(90)cylinder(d=d1,h=asz-.5,center=true,$fn=30);
        z(ih/2-ha) cube([asz-2*iw,msz,ih],center=true);
    }
    module f2() {
        z(ih-ha+ih)cube([asz-2*iw,d1+1,ih+ih],center=true);
        cylinder(d=d2,h=hsz*3,center=true,$fn=23);
        z(-ha+ih-d2h)cylinder(d=d2+2,h=d2h+.1,$fn=19);
        hull() let(rp=ha-ih,ro=asz/2-iw-rp/2)
        for(x=[-ro,ro],y=[0,rp])translate([x,0,y])
         rx(90)cylinder(r=rp,h=2,center=true,$fn=23);
    }
    difference() {
        union(){f0();f1();}
        f2();
    }
}

z(-14.5)stickA();
z(-14.5)stickB();

mntplate();
//translate([0,52/2,0]) rx(90)sideplate();
//rz(90)translate([0,52/2,0]) rx(90)sideplate();
