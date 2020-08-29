
wall=1.5;// thin elements wall
dstick=3; // outer dsitck diameter
daxle=1.5; // rotating pin diameter
tol=0.2; // movable elements tolarance luft
dmnt=9; // axis exit hub diameter
// general axis prarm
laxis=32;
// central hub param
dcros=7.5; // internal axis diameter
hcros=19.8; // internal axis length
wcros=5; // gimbal cross wheel
wheel=22; // central wheel diameter
// yaxis and cover param
dcap=23; // cap diameter
lcap=29; // cap axial lenght
capcut=0.5; // ycap cur
wsize=12; // stick window size
dcov=18; // xcover height
// mount base
mountsz=40; // x,y size
mountlck=16; // lock path size
mounth=dcap/2-capcut-wall; // axis offset
mountw=16; // window size
standsz=5;  // x,y stand size
standh=mounth+dcap/4;// stand height
standz=[4,6,8,11]; // reference and bolt offset


*let(a=$t*360,r=30,
    m=r*sin(a*2)*sqrt(2)/2,
    x=cos(a)-sin(a),y=sin(a)+cos(a))
{
    rotate([x*m,0])ycap();
    rotate([0,y*m])xcov();
    rotate([x*m,y*m])
    { 
        //color([.6,.6,.6])cylinder(d=dstick,h=40,$fn=23);
        crosup();
        crosdn();
    }
    z(mounth){
        mountbase();
        for(j=[0:90:359])rz(j)
        z(wall)
        translate([0,mountsz/2])ry(180)rx(90)sideplate();
    }
}

//crosup();
//crosdn();
//ycap();
//xcov();
mountbase();
//sideplate();

module z(offs) translate([0,0,offs]) children();
module rx(angle) rotate([angle,0,0]) children();
module ry(angle) rotate([0,angle,0]) children();
module rz(angle) rotate([0,0,angle]) children();

module crosup() {
    u=dcros/2;
    module f1()
    for(j=[[90,0],[0,90]]) rotate(j) // crossing
        cylinder(d=dcros,h=hcros,center=true,$fn=30);
    module f2(d=wheel) // round top
    rx(90) intersection() { 
      cylinder(d=d,h=wcros,$fn=40,center=true);
      sphere(d=d,$fn=66);
      rx(-90)linear_extrude(height=d/2,scale=wheel/(hcros/3))
        translate([-hcros/4,-wcros/2])square([hcros/2,wcros]);
    }
    module f3() {// cutawat
        cylinder(d=dstick,h=hcros,$fn=23); // stick
        for(a=[0:90:359])rz(a)rx(90)z(hcros/2-5) // axle
            cylinder(d=daxle,h=hcros,$fn=23);
        z(-u)cube([hcros+1,hcros+1,u],center=true);
    }
    module f4() z(-u)linear_extrude(height=u,convexity=6)
        projection(cut=false)f1();
    difference() {
        union() { f1(); f2(); f4(); }
        f3();
    }
}

module crosdn() {
}

module axialdrill() for(y=[0:90:359]) rz(y) rx(90) z(dcap/2-wall-wall)
        cylinder(d=daxle,h=hcros,$fn=23);

module ycap() {
    omnt=lcap/2-wall;
    imnt=dcap/2-wall;
    idcap=dcap-wall*2;
    ilcap=lcap-wall*2;
    hub=laxis/2-omnt;
    module outer() intersection() {
        ry(90)cylinder(d=dcap,h=lcap,center=true,$fn=50);
        z(-capcut) cube([lcap,dcap,dcap],center=true); // flat cut
    }
    module inner() {
      intersection() {
        ry(90)cylinder(d=idcap,h=ilcap,center=true,$fn=50);
        z(-capcut) cube([lcap,dcap,idcap],center=true); // flat cut
      }
      z(-dcap/2)cube([lcap+1,dcap+1,dcap],center=true); // half cut
      hull() for(x=[-1,1]*wsize/2) translate([x,0,0]) // stick path
            cylinder(d=wcros+tol,h=dcap,$fn=30);
      for(y=[90,270]) rx(y) z(imnt-wall) // hub cutout
        cylinder(d=dcros+tol*4,h=wall,$fn=30);
    }
    module axes() for(x=[0,180]) rz(x) ry(90)z(omnt) hull() {
        cylinder(d=dmnt,h=hub,$fn=30);
        translate(-[dcap+dmnt,0,0]/4)cylinder(d1=wall,d2=0,h=wall);
    }
    module lugs() intersection() { outer(); 
        for(y=[90,270]) rx(y) z(imnt) 
        cylinder(d=dcros,h=wall,$fn=30);
    }

    difference() { outer(); inner(); axialdrill(); }
    difference() { union() { axes(); lugs();} axialdrill(); }
}

module xcov() {
    omnt=lcap/2-wall;
    imnt=dcap/2-wall;
    hub=laxis/2-omnt;
    z1=(dmnt+wall)/.8;

    module j1(th=wall)
      rx(-90) z(omnt) cylinder(d=dmnt,h=th,$fn=30);
    module j2()
      translate([0,omnt*2+wall,-z1]/2)
      ry(90) cylinder(d=wall,h=dmnt,center=true,$fn=30);
    module j1i()
      ry(-90) z(imnt)  cylinder(d=dcros,h=wall,$fn=30);
    module j2i()
      translate([-imnt*2-wall,0,-dcros]/2)
      rx(90) cylinder(d=wall,h=dcros,center=true,$fn=30);
    module j3() rz(-90) 
      translate([-omnt-wall/2+(dcov-z1)/2,0,-dcov/2])
      rx(90) cylinder(d=wall,h=dmnt,center=true,$fn=30);
    module j4()
      translate(-[omnt,0,dcov]/2)
      rx(90) cylinder(d=wall,h=dmnt,center=true,$fn=30);
    module mainaxis() {
        for (y=[0,180]) hull() rz(y){ j1(); j2(); } // arm
        for (y=[0,180]) rz(y) j1(hub);              // hub
        for (y=[0,180]) hull() rz(y){ j2(); j3(); } // subarm
    }
    module orthoaxis() {
        for (y=[0,180]) hull() rz(y){ j1i();j2i();} //  arm
        for (y=[0,180]) hull() rz(y){ j2i();j4(); } //  subarm
    }
    module bottom() 
        hull() for (y=[0,180]) rz(y) { j3(); j4(); } // down plate
    difference() {
        union() {mainaxis(); orthoaxis();}
        axialdrill();
    }
    bottom();
}

module mountbase()
{
    xy=mountsz-2*wall;
    xy1=(mountsz-mountlck)/2;
    module f1() {
        translate(-[xy,xy,0]/2)cube([xy,xy,wall]);
        for(j=[0:90:359])rz(j) translate([mountlck/2,mountlck/2])
            cube([xy1,xy1,wall]);
    }
    module f2()
        cube([lcap+tol,mountw,wall*3],center=true);
    module f3(d=12) {
            z(-.1) cube([standsz,standsz,standh+.1]);
            hull() for(t=[0,90])rx(t) z(-.1)cube([wall,d,.1]);
            hull() for(t=[0,90])ry(-t) z(-.1)cube([d,wall,.1]);
        }

    module stand() {
        difference() {
            f3();
            translate([0,standsz/2,standz[0]]) rx(45)cube(2,center=true);
            translate([standsz/2,0,standz[1]]) ry(45)cube(2,center=true);
            translate([0,standsz/2,standz[2]]) ry(90) {
                z(standsz) cylinder(d=4,h=2,center=true,$fn=6);
                cylinder(d=2,h=standsz*3,center=true,$fn=23);
            }
            translate([standsz/2,0,standz[3]]) rx(90) {
                z(standsz) cylinder(d=4,h=2.1,center=true,$fn=6);
                cylinder(d=2,h=standsz*3,center=true,$fn=23);
            }
        }
    }

    difference() { f1(); f2(); }
    for(j=[0:90:359])rz(j)
        translate([xy/2,xy/2,0])rz(90)ry(180)stand();
}

module sideplate()
{
    xy=mountsz-2*wall;
    ax=mounth+wall;
    deep=wall+(xy-laxis)/2-.1;
    
    module f1() {
        translate([-xy/2,wall])cube([xy,standh,wall]);
        translate(-[mountlck-.1,0]/2)cube([mountlck-.1,wall*2,wall]);
        translate([-xy/2+standsz/2,standz[0]+wall,wall])
                rz(45)cube(2,center=true);
        translate([xy/2-standsz/2,standz[1]+wall,wall])
                rz(45)cube(2-.1,center=true);
    }
    module f2()
        translate([0,ax])
        cylinder(d=dmnt,h=deep);
        
    difference() {
        union() { f1();f2(); }
        z(-.1) translate([0,ax])cylinder(d=daxle,h=deep+.2,$fn=23);
        translate([xy/2-standsz/2,standz[3]+wall,0])
                cylinder(d=2,h=standsz*3,center=true,$fn=23);
        translate([-xy/2+standsz/2,standz[2]+wall,0])
                cylinder(d=2,h=standsz*3,center=true,$fn=23);
    }
}
