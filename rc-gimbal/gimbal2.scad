
wall=1.5;// thin elements wall
dstick=3; // outer dsitck diameter
daxle=1.5; // rotating pin diameter
tol=0.2; // movable elements tolarance luft
dmnt=9; // axis exit hub diameter
// general axis prarm
laxis=32;
// yaxis and cover param
dcap=23; // cap diameter
lcap=29; // cap axial lenght
capcut=0.5; // ycap cur
wsize=12; // stick window size
dcov=23; // xcover height
// central hub param
dcros=5.5; // internal axis diameter
//hcros=18.8; // internal axis length
hcros=dcap-2*wall-tol; // internal axis length
wcros=5; // gimbal cross wheel
wheel=22; // central wheel diameter
// mount base
mountsz=40; // x,y size
mountlck=16; // lock path size
mounth=dcap/2-capcut-wall; // axis offset
mountw=20; // window size
standsz=5;  // x,y stand size
standh=mounth+dcap/4;// stand height
standz=[4,6,8,11]; // reference and bolt offset


let(a=$t*360,r=30,
    m=r*sin(a*2)*sqrt(2)/2,
    x=cos(a)-sin(a)
    //x=0
    ,
    y=sin(a)+cos(a)
    //y=0
    )
{
    rotate([x*m,0])ycap();
    rotate([0,y*m])xcov();
    rotate([x*m,y*m]) 
      color([.6,.6,.6])cylinder(d=dstick,h=40,$fn=23);
    ry(y*m)
    rx(x*m) crosup();
    rx(x*m)
    ry(y*m) crosdn();
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
//z(mounth)
//mountbase();
//sideplate();

module z(offs) translate([0,0,offs]) children();
module rx(angle) rotate([angle,0,0]) children();
module ry(angle) rotate([0,angle,0]) children();
module rz(angle) rotate([0,0,angle]) children();

module crosup() {
    u=dcros/2;
    module f1() hull() {
        rx(90)
            cylinder(d=dcros,h=hcros,center=true,$fn=30);
        cube([dcros,hcros/2,dcros],center=true);
    }
    module f2(d=wheel) // round top
    rx(90) intersection() { 
      cylinder(d=d,h=wcros,$fn=40,center=true);
      sphere(d=d,$fn=66);
      rx(-90)z(dcros/2-.1)
        linear_extrude(height=d/2-dcros/2,scale=wheel/(wcros/2))
        square([wcros,wcros],center=true);
    }
    module f3() {// cut
        z(5)cylinder(d=dstick,h=hcros,$fn=23); // stick
        axialdrill(hcros/2-5);
        z(-u-.01)cylinder(d=daxle,h=u*2,$fn=23);
        }
    difference() {
        union() { f1(); f2(); }
        f3();
    }
}

module crosdn() {
    h=hcros/3;
    h1=1;
    width=dcros+h1;
    module zdrill() z(-h+h1) cylinder(d=daxle,h=h,$fn=23);

    module f1() {
        ry(90)
        cylinder(d=dcros,h=hcros,center=true,$fn=30);
        intersection() {
            rx(90)
            sphere(d=hcros,$fn=90);
            z(-h/2)
                 cube([hcros,wcros,h],center=true);
        }
    }
    module f2() {
        cube([dcros,dcros,dcros/2+h1/2]*2,center=true);
        rz(90)axialdrill(width);
        zdrill();
    }
    module f3()
        z(-dcros/2-h1-.1) cylinder(d=wcros,h=1,$fn=30);
    difference() { f1(); f2(); }
    difference() { f3(); zdrill(); }
}

module axialdrill(base=dcap/2-2*wall)
    for(y=[0,180]) rz(y) rx(90) z(base)
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

    difference() { outer(); inner(); for(t=[0,90])rz(t)axialdrill(); }
    difference() { union() { axes(); lugs();} for(t=[0,90])rz(t)axialdrill(); }
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
        for(t=[0,90])rz(t)axialdrill();
    }
    bottom();
}

module mountbase()
{
    xy=mountsz-2*wall;
    xy1=(mountsz-mountlck)/2;
    nut=4;
    nuth=1;
    refsz=2;
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
    module f4(h=3)z(wall)
        translate([0,mountw/2])rx(180+45)
        translate(-[lcap+tol,0,0]/2) cube([lcap+tol,h,wall]);

    module stand() {
        difference() {
            f3();
            translate([0,standsz/2,standz[0]]) rx(45)cube(refsz,center=true);
            translate([standsz/2,0,standz[1]]) ry(45)cube(refsz,center=true);
            translate([0,standsz/2,standz[2]]) ry(90) {
                z(standsz) cylinder(d=nut,h=nuth*2,center=true,$fn=6);
                cylinder(d=2,h=standsz*3,center=true,$fn=23);
            }
            translate([standsz/2,0,standz[3]]) rx(90) {
                z(-standsz)rz(90)cylinder(d=nut,h=nuth*2,center=true,$fn=6);
                cylinder(d=2,h=standsz*3,center=true,$fn=23);
            }
        }
    }

    difference() { f1(); f2(); }
    for(j=[0,1])mirror([0,j])f4();
    for(j=[0:90:359])rz(j)
        translate([xy/2,xy/2,0])rz(90)ry(180)stand();
}

module sideplate()
{
    xy=mountsz-2*wall;
    ax=mounth+wall;
    deep=wall+(xy-laxis)/2-.1;
    refsz=2;
    module f1() {
        translate([-xy/2,wall])cube([xy,standh,wall]);
        translate(-[mountlck-.1,0]/2)cube([mountlck-.1,wall*2,wall]);
        translate([-xy/2+standsz/2,standz[0]+wall,wall])
                rz(45)cube(refsz-tol/2,center=true);
        translate([xy/2-standsz/2,standz[1]+wall,wall])
                rz(45)cube(refsz-tol/2,center=true);
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

module dexpmnt() {
    z(-18)cylinder(d=38,h=18,$fn=81);
    z(-5) for(x=[-.5,.5],y=[-.5,.5])translate([x,y]*30) 
        cylinder(d=1.5,h=5,$fn=15);
    module dx(x) let(sz=40,d=199)
        translate([x,0]*sz/2)translate([-x*d/2,0])cylinder(d=d,h=2,$fn=200);
    intersection() { dx(-1); dx(+1); rz(90) dx(-1); rz(90) dx(1);} 
        
}

//#dexpmnt();
