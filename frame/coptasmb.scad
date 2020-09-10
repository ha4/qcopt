module co_arm0() {
    translate([-54.945,-102.27,0])
    import(file="quad_arm_repaired.stl");
    //#cylinder(d=6.5,h=5,$fn=40);
    }

module co_center0() {
    translate([-88.4,-88.40,0])
    import(file="Center_plate_top_repaired.stl");
}
module co_bottom0() {
    translate([-88.4,-88.40,0])
    import(file="Bottom_plate_repaired.stl");
}

module co_x2204($fn=50,b=[.2,.2,.2]) {
    difference() {
        color(b)cylinder(d2=28,d1=25.4,h=2.2);
        for(j=[-.5,.5]) {
            translate([16*j,0,0]) cylinder(d=3,h=5,center=true);
            translate([0,19*j,0]) cylinder(d=3,h=5,center=true);
        }
    }
    color(b) rotate([0,0,45]) translate([0,-8/2,0]) cube([25,8,3.5]);
    translate([0,0,2.2])cylinder(d=28,h=16-2.2);
    translate([0,0,16])cylinder(d1=28,d2=5,h=20.5-16-2.2);
    cylinder(d=5,h=10+20.5);
}

module co_5040(b=[0,0,.3,.3])
    color(b)hull() {
        cylinder(d=14.5,h=7.8,center=true);
        cylinder(d=5*25.4,h=2,center=true);
    }

module co_bat2200(w=[.8,.8,.8])
    color(w) let(sz=[35,116,0]) translate(-sz/2)cube(sz+[0,0,30]);

/*
    center plate
 */
module f1(a=0) let(w=16,h=92)
    rotate([0,0,45]) translate([-(w+a)/2,-h/2,0]) square([w+a,h]);
module j1(i,r=95) let(a=r-r*cos(i), b=r-r*sin(i)) intersection()
    { f1(b);  rotate([0,0,90]) f1(a); }
module bevel1() 
    for(i=[0:5:90]) hull() {j1(i); j1(i+5); }

module arm_mnt(full=true) {
    circle(d=3.5,$fn=30);
    if(full) for(i=[-.5,.5]) translate([i*15,-14.5])
        circle(d=3.5,$fn=30);
}

module rpath(x,y) hull()
    if (x>=y)
        for(i=[-x+y,x-y]/2) translate([i,0]) circle(d=y,$fn=30);
    else
        for(j=[-y+x,y-x]/2) translate([0,j]) circle(d=x,$fn=30);

module belt_mnt(a,w=20,d=3)
    for(x=[-a,a]/2) translate([x,0])
        rpath(d,w);

module sqr_hole(w,h,d=3.2)
    hull()
        for(x=[-w+d,w-d]/2,y=[-h+d,h-d]/2) translate([x,y])
            circle(d=d,$fn=30);

module co_center() linear_extrude(height=2)
  difference() {
    bevel1();
    // electronics
    let(m=30.5,g=[m,-m]/2)for(x=g,y=g) translate([x,y])
            circle(d=3.5,$fn=30);
    // what for?
    let(m=45,g=[m,-m]/2)for(x=g,y=g) translate([x,y,0])
            circle(d=3.5,$fn=30);
    // arm
    let(m=41)for(a=[0:90:359])rotate([0,0,a+45])translate([0,m,0])
        arm_mnt();
    // belt
    belt_mnt(52);
    belt_mnt(32);
    // vhent
    for(y=[-15.25,15.25]) translate([0,y,0]) sqr_hole(12.7,6.35);
}

/*
    bottom plate
 */

module f2a(a=0) let(dx=8,L=50)
    translate([-a/2,0,0])rotate([0,0,45])
        translate([L-dx,0,0])circle(d=dx+a,$fn=70);
module f2b(a=0) let(w=36,h=123)
    sqr_hole(w=w+a,h=h,d=10);

module j2(i,r=50) let(a=r-r*cos(i), b=r-r*sin(i)) intersection()
    { f2b(b);  f2a(a); }
module bevel2() for(i=[0:5:90]) hull() {j2(i); j2(i+5); }
module symm4() for(n=[0:1],m=[0:1]) 
    mirror([n,0,0]) mirror([0,m,0]) children();

module co_bottom() linear_extrude(height=2)
  difference() {
    union() {
        f2b();
        symm4() bevel2();
        hull() symm4() f2a();
    }
    let(m=41)for(a=[0:90:359])rotate([0,0,a+45])translate([0,m])
        arm_mnt(0);

    let(r=160,dx=62.6) 
    for(n=[0,1])mirror([n,0])
        translate([r+dx/2,0]) circle(r=r,$fn=90);
    belt_mnt(52);
    belt_mnt(32);
    // vhent
    for(y=[-24,24]) translate([0,y]) sqr_hole(27,10);
    sqr_hole(12.7,12.7);
    // other mnt
    rotate([0,0,90])belt_mnt(80,17.5,2.5);
    for(y=[-51.28,51.28]) translate([0,y]) belt_mnt(26,12.5,2.5);
}
//let(n=8)for(i=[0:n]) translate([0,0,-i*3])j2(i*90/n);

/*
    motor arm
 */

module cros(wall,sz1,sz2,h)
    for(a=[-45,45]) rotate([0,0,90+a])
    translate(-[sz1,wall/2,0])cube([sz1+sz2,wall,h]);

function lenangle(length, diameter) = 360*length/diameter/3.1415926535;

function rotpts(dp)=atan2(dp.x,dp.y);

function center2pr(p1,p2,r) = let(c1=(p1+p2)/2, c=p2-p1, n=[c.y,-c.x], 
		nn=norm(n), h=nn/2, y=r<h?0:sqrt(r*r-h*h), ofs=nn==0?[0,0]:y/nn*n) c1-ofs;
   
module ringsect(sz,r) {
    a=asin(sz.y/r/2)*2;
    rotate([0,0,-a/2])
    translate([-r,0,0])
    rotate_extrude(angle=a,$fn=200)
        translate([r,0,0]) square([sz.x,sz.z]);
}

module arm_mounts(d,h1,h2) {
    w=15;
    e3=14.5;
    curv=290;
    armbase=d/2+1.5;
    mntwidth=17.65;
    
    p1=[mntwidth/2,armbase];
    p2=[(w+d)/2,-e3];
    ab=rotpts(p1-p2);
    nb=norm(p1-p2);
    difference() {
        union() {
        // bolts
        for(i=[-.5,.5])
        translate([i*w,-e3,0]) cylinder(d=d,h=h1,$fn=30);
        if (h2>0)
        cylinder(d=d,h=h2,$fn=40);
        else
        translate([0,0,h2+h1]) cylinder(d=d,h=-h2,$fn=40);
        // holders
        translate([-mntwidth/2,armbase-d,0])
            cube([mntwidth,d,h1]);
        for(j=[0,1])mirror([j,0,0])
            translate(p1) rotate([0,0,180-ab])
                ringsect([d*.75,nb,h1],curv);
        }
        linear_extrude(height=abs(h2)*4,center=true,convexity=3)
            arm_mnt();
    }
}

module arm_frame(L,w1,wall,h,h2) {
    curv=290;
    mntwidth=17.65;
    p1=[mntwidth/2,L];
    p2=[w1/2-.5,-w1/2+4];
    ab=rotpts(p1-p2);
    nb=norm(p1-p2);
    wx=w1/2;

    translate(-[wall/2,0,0])cube([wall,L,h]);
    for(y=[ [0,0,wx-.5],
            [14.35,wx-.5,wx-2.5],
            [14.35+12.25,wx-2.5,wx-3],
            [14.35+12.25+11.25,wx-3,wx-4],
            [14.35+12.25+11.25+11,wx-4,wx-3],
            [14.35+12.25+11.25+11+11.8,wx-3,wx-2]])
        translate([0,y[0]-.4,0]) cros(wall,y[1],y[2],h);
    for(j=[0,1])mirror([j,0,0])
    translate(p1) {
        translate(p2-p1)rotate([0,90,9])translate([-h2/2,0,-wall])cylinder(d=h2,h=wall,$fn=30);
        rotate([0,0,180-ab])ringsect([wall,nb,h2],curv);
    }
}

module mot_mnt(d1=6.5,d2=3.2) {
    m=[19,16]/2;
    cylinder(d=d1,h=9,center=true,$fn=30);
    for(a=[0:90:359]) rotate([0,0,a+45])
        hull()for(j=m)translate([j,0])
            cylinder(d=d2,h=9,$fn=31);
}

module co_arm(sz=125, bsz=41, dmot=24, h=4, hm=6, htot=18, wall=2) {
    frames=6;
    dmnt=7.5;
    asz=sz-bsz;
    // motor plate
    difference() {
        cylinder(d=dmot,h=h,$fn=60);
        mot_mnt();
    }
    // arm mounts
    translate([0,-asz,0])
        arm_mounts(dmnt,hm,htot);
    translate([0,-dmot/2,0]) rotate([0,0,180])
        arm_frame(asz-dmot/2-dmnt/2-1.5,
            dmot,wall,h,hm);
}

module co_arm2(sz=125, bsz=41, dmot=27, h=4, hm=6, htot=18, wall=2) {
    frames=6;
    dmnt=7.5;
    asz=sz-bsz;
    // motor plate
    difference() {
        cylinder(d=dmot,h=h,$fn=60);
        mot_mnt();
    }
    // arm mounts
    translate([0,-asz,0])
        arm_mounts(dmnt,hm,-htot);
    translate([0,-dmot/2,0]) rotate([0,0,180])
        arm_frame(asz-dmot/2-dmnt/2-1.5,
            dmot,wall,hm,hm);
}

//co_arm0();
//co_arm();

module drillptrn(x=30.5,xs=36,ds=10,d=3.2,d0=7.5,h1=2,h2=15,pcb=1.5,tol=.2,clamp=false,$fn=40)
{
    g=[for(xx=[-.5,.5],yy=[-.5,.5]) [x*xx,x*yy]];
    diag=x*sqrt(2);
    if(!clamp)
    difference() {
      union() { hull() for(c=g) translate(c) cylinder(d=d0,h=h1);
      for(c=g) translate(c) cylinder(d=d0,h=h2); 
      for(a=[0,90])rotate([0,0,45+a])translate(-[1,diag]/2)cube([1,diag,h2]);    
      }
      
      for(c=g) translate(c) cylinder(d=d,h=h2*3,center=true);
      for(a=[0:90:359])rotate([0,0,a])translate([xs/2,-d0/2,-1])
          cube([d0,d0,h1*2]);
      
      for(a=[0:90:359])rotate([0,0,a])translate([xs/2,-d0/2,-1])
          cube([d0,d0,h1*2]);
      for(a=[0:90:359])rotate([0,0,a])translate([xs/2-ds,-d0/2,-1])
          cube([ds/2,d0,h1*2]);
      }
    pos1=xs/2-ds+tol/2;
    pos2=xs;
    if (clamp)
    rotate([90,0,0])
    translate([pos2,-d0/2+tol/2,2]) {
            cube([ds+d0/2-tol/2,d0-tol,h1*2]);
        translate([0,0,-h1])
            cube([ds/2-tol,d0-tol,h1*2-h1]);
        translate([ds-tol/2,0,-h1-pcb])
            cube([ds/2,d0-tol,h1*2-h1+pcb]);
    }
}

module assembly() {
fsz=250; // frame size
for(a=[0:90:359]) rotate([0,0,a+45])translate([0,fsz/2,0]) rotate([0,180,0]) translate([0,0,18-6])co_arm2();
    //co_arm();
translate([0,0,-2.0-18.0])
co_center();
co_bottom();
translate([0,0,2])co_bat2200();
translate(-[0,0,18-6])
for(a=[0:90:359]) rotate([0,0,a+45])translate([0,fsz/2,0]) {
    rotate([0,0,-45-90]) co_x2204();
    translate([0,0,22]) co_5040();
}
}

assembly();
//drillptrn(clamp=false);
//co_arm2();
//co_bottom();
//co_center();