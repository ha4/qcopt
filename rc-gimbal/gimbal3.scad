wall=2.5;
module z(offs) translate([0,0,offs]) children();
module rz(angle) rotate([0,0,angle]) children();
module ry(angle) rotate([0,angle,0]) children();
module rx(angle) rotate([angle,0,0]) children();
module ring(a,d1,d2,h,center=false) rz(-a/2)
 rotate_extrude(angle=a,convexity=5)
 translate([d1/2,0,center?-h/2:0])square([d2/2-d1/2,h]);
module rring(a,d1,d2,h,center=false) {
 ring(a,d1,d2,h,center); let(t=[d1+d2,0]/4)
 for(j=[-1,1])rz(j*a/2)translate(t)
     cylinder(d=d2/2-d1/2,h=h,center=center);
 }

//rring(60,25,30,3,$fn=55); #cylinder(d=25,h=3);

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
        cylinder(d=cd,h=cw); // cup
        intersection() { // stick bed
            cylinder(d=cd,h=cw*10,center=true);
            z(cw)rx(180)
                rramp([ww,wh]+[wall,wall]*2,[ww1,wh1]+[wall,wall]*2,2,wz);
        }
        // rotation stopper
    }
    module f2i() { // cover cutout
        z(cw+.01)rx(180)
        rramp([ww,wh],[ww1,wh1]+[wall/2,-wall/2],2,wz+.03); // stick bed
        z(-axial) ry(90) // drum bed
        cylinder(r=wr-wdw,h=2*ww,center=true,$fn=43);
    }
    module f2a() {
        z(-axial)ry(90)difference() {
            cylinder(r=wr,h=ww-wall,center=true,$fn=43); // cylindrical shileld
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
            union() let(ds=4) {
                cylinder(d=ds,h=bh,$fn=19);
                translate([-ds/2,-ds/2])cube([ds/3,ds,bh]);
            }
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

module spring1() 
color([.5,.5,.5]){
    wall=0.5;
    z(-wall) difference() {
        union() {
            translate(-[6,4.1]/2)cube([6,4,wall]);
            translate(-[6,4+wall*2]/2)cube([6,wall,3]);
            translate(-[4,4]/2)cube([4,22,wall]);
            translate([0,18,wall/2])ry(90)
                cylinder(d=wall*2,h=4,center=true,$fn=15);
        }
        cylinder(d=2.2,h=wall*4,center=true,$fn=19);
    }
}

module sideplate()
{
    wall1=1;
    offs1=14.5;
    bol=[[-52/2+3.5,-wall-9.5],[52/2-3.5,-wall-13.5]];
    module f1() z(-wall) {
        translate([-51/2,-17-2.5])cube([51,17,wall]);// main
        translate([-20/2,-wall-.5]) cube([20,wall+.5,wall]); // lock
        translate([0,-offs1]) cylinder(d=8,h=7,$fn=31); // center
        translate([0,-offs1+2])for(j=[-45,45])rz(j)  // stopps
            translate([-wall1/2,0])cube([wall1,12,7]);
        // refs
        translate([-52/2+3.5,-wall-2.5]) cylinder(d=2,h=wall+1,$fn=21);
        translate([52/2-3.5,-wall-5.5]) cylinder(d=2,h=wall+1,$fn=21);      
        // bolts
        for(j=bol) translate(j) cylinder(d=7,h=wall,$fn=21);
    }
    module f2() for(j=bol) translate(j) { // bolts
        cylinder(d=2.2,h=wall*3,center=true,$fn=21);
        z(-2-wall+1)cylinder(d=4.6,h=2.01,$fn=21);
        z(-wall+1)cylinder(d1=4.6,d2=2.2,h=1,$fn=21);
    }

    difference() {
        f1();
        translate([0,-offs1]) cylinder(d=4,h=7*3,center=true,$fn=31);
        f2();
    }
}

module stickA()
{
    d1=1.5;
    d2=4;
    d3=3;
    asz=25;
    do=27;
    stkoffs=6;
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
        z(stkoffs)cylinder(d=d2,h=do,$fn=19);
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
         ry(90)cylinder(d=d1-2,h=asz,center=true,$fn=30); // axis limiter
         ry(90)cylinder(d=d0,h=asz+2*lext,center=true,$fn=30); // axis
   }
    module f1() hull() { // main body
        ry(90)cylinder(d=d1,h=asz-.5,center=true,$fn=30);
        z(ih/2-ha) cube([asz-2*iw,msz,ih],center=true);
    }
    module f2() { // extracts
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

module ydrum()
{
    asz=42.5; // main axial length
    aext=4;   // axial extend
    dax1=4;   // support axis
    dax2=6;   // pot axis
    dax2b=1.5;// pot axis flat
    dax0=1.5; // orthogonal axis
    wall=2;   // inner wall
    r0=15;    // outer radial size
    r1=13;    // side radial size
    h0=26.8;  // outer size
    h1=40.5;  // drum size
    zext=3;   // extra drum height
    hint=2.5; // internal cut height
    zint=20;  // internal cut width
    ph=7.8;   // path cut height
    pw=20;    // path cut width
    pw1=pw+2; // biggest path cut
    dmnt=8.5; // orthogonal axis size
    rkr1=9;   // rocker stopper1
    rkr2=4;   // rocker stopper2
    module f0() let(z=asz/2+aext) ry(90) intersection() { // axial pot cut
        cylinder(d=dax2,h=z,$fn=43);
        translate([-dax2b,0,0])cube([dax2,dax2,z+z],center=true);
    }
    module f1() ry(90) {
        cylinder(r=r0,h=h0,center=true,$fn=43);
        cylinder(r=r1,h=h1,center=true,$fn=43);
    }
    module f2() ry(90) {
        cylinder(r=r0-wall,h=h0-wall*2,center=true);
        cylinder(r=r1-wall,h=h1-wall*2,center=true);
        translate([r0,0,0])cube([r0*2,r0*2,h1+1],center=true);
        translate([r0-hint,0,0])cube([r0*2,r0*2,zint],center=true);
        ry(-90)linear_extrude(height=r0,scale=[pw1,1]) square([1,ph],center=true);
        cube([r0*2,ph,pw],center=true);
    }
    module f2a() difference() { f1(); f2(); f0(); }
    module f2b() z(-zext+.01)linear_extrude(height=zext)
        projection(cut=true)z(-.01) f2a();
    module f3() rx(90){ // orthogona axis lug
        intersection() {
            let(wall0=wall+.4)difference() {
              for(m=[-r0,r0-wall0]) z(m) {
                 cylinder(d=dmnt,h=wall0);
                 translate([-dmnt/2,0])cube([dmnt,dmnt/2,wall0]);
              }
              cylinder(d=dax0,h=r0*3,center=true,$fn=13);
            }
            ry(90) cylinder(r=r0,h=h0,center=true,$fn=43);
        }
    }
    module f4() ry(90) z(-h1/2+.01){ // support axis & stopper protection
        let(dh=(asz-h1)/2+.15)
        z(-dh)cylinder(d=dax1+2,h=dh,$fn=19);
        z(-aext)cylinder(d=dax1,h=aext,$fn=19);
        z(-aext+2)for(j=[-10,10])translate([0,j,0])
            cylinder(d=3.1,h=aext-2,$fn=19);
        z(0) intersection() {
            cylinder(r=15.5,h=wall,$fn=67);
            translate([0,-18/2])cube([31,18,wall]);
        }
    }
    module f5() ry(90) z(h1/2-wall) { // pot axis
        cylinder(d=dax2+wall*2,h=aext+wall,$fn=31);
    }
    module f6() ry(90) z(h1/2-wall) let(dr=1.5) { // pot axis locker
        // ###FIXME stopper location
        translate([dr/2,-rkr2,0]) hull() {
            cylinder(d=dr,h=aext+wall,$fn=23);
            translate([dr,0,0])cylinder(d=dr,h=aext+wall,$fn=23);
        }
        translate([dr/2, rkr1,0]) hull() {
            cylinder(d=dr,h=aext+wall,$fn=23);
            translate([dr,-dr/2,0])cylinder(d=dr,h=aext+wall,$fn=23);
            translate([dr,0,0])cylinder(d=dr,h=aext+wall,$fn=23);
        }
    }
    module f7() { // ###FIXME drum stopper
        ring(360-90,25,30,5);
    }

    
    f2a();
    f2b();
    f3();
    f4();
    difference() {
        f5(); f0(); 
        let(u=dax2+wall*3) translate([asz/2,-u/2,-zext/2]) cube([u,u,u]);
    }
    f6();
}

module xcap()
{
    wall=3.5;
    sz=15; // general axis-bottom size
    asz=42.5; // main axial length
    aext=4;   // axial extend
    a0sz=20.5; // ortho axis lenght
    d0=3; // ortho axis
    d0d=7; // lug diameter
    d1=4; // support axis
    d2=6; // pot axis
    d2b=1.5;// pot axis flat
    lug0=4; // lug szie
    lug0a=15; // lug arm size
    lug0b=12; // lug arm size
    lug0z=3.5; // lug arm isosurface
    lug0d=8.5; // lug arm height
    lug1=4.5; // main axis lug depth
    lug1h=8; // main axis lug height
    lug1w=21; // main axis lug width
    lug1a=8.5; // arm width
    lug1d=7;   // arm height
    rkr1=9;   // rocker stopper1
    rkr2=4;   // rocker stopper2
    module f0() let(z=asz/2+aext) rx(90) intersection() { // axial pot cut
        cylinder(d=d2,h=z,$fn=43);
        translate([0,d2b])cube([d2,d2,z+z],center=true);
    }
    module f00() ry(90) // orthogonal axial drill
        cylinder(d=d0,h=a0sz+lug0*3,center=true,$fn=43);

   module f1a() // orthogonal lug itself
        ry(90) z(a0sz/2)cylinder(d=d0d,h=lug0,$fn=31);
    module f1b() // orthogonal lug step1
        translate([a0sz/2,-lug0b/2,-lug0z]) cube([lug0,lug0b,.1]);
    module f1c()
         translate([a0sz/2-2.0,-lug0a/2,-lug0d]) cube([lug0,lug0a,.1]);
    module f1d()
        translate([a0sz/2-2.5,0,-sz+wall/2])
            rx(90) cylinder(d=wall,h=lug0a,center=true,$fn=39);
    module f1() {
        hull() { f1a(); f1b(); }
        hull() { f1b(); f1c(); }
        hull() { f1c(); f1d(); }
    }
    module f2()  { // lug
       rx(90) z(-asz/2+.5) hull() let(k=lug1w-lug1h*2) for(j=[-k,k])
           translate([j,0])cylinder(d=lug1h,h=lug1,$fn=31);
       translate([-lug1a/2,asz/2-lug1-.5,-lug1d])
            cube([lug1a,lug1,lug1d+lug1h/2+1]);
    }
    module f3() rx(90)  { // support axis
       z(-asz/2)cylinder(d=d1+2,h=.5+.01);
       z(-asz/2-aext)cylinder(d=d1,h=aext+.5,$fn=43);
    }
    module f4a() // arm start
        translate([-lug1a/2,asz/2-lug1-.5,-lug1d]) cube([lug1a,lug1,2]);
    module f4b()// arm start
        translate([-lug1a/2,asz/2-1-lug1d,-sz]) cube([lug1a,1,wall]);
    module f4() hull() {
        f4a(); f4b();
    }
    module f5() let(r=4) difference() {
        hull() {
            f1d(); rz(180) f1d(); 
            f4b(); rz(180) f4b();
            }
        for(i=[0,1],j=[0,1])
        mirror([0,i,0])mirror([j,0,0])let(x=[lug1a/2+r,lug0a/2+r,0])
            translate(x) z(-sz) hull() for(m=[[0,0],[0,r],[r,0]])
                translate(m)cylinder(r=r,h=wall*3,center=true,$fn=39);
    }
    module f6() rx(90) z(asz/2-.5-lug0) let(dr=1.5) { // pot axis locker
        // ###FIXME stopper location
        translate([-rkr2,-dr/2]) hull() {
            cylinder(d=dr,h=aext+wall,$fn=23);
            translate([dr/2,-dr,0])cylinder(d=dr,h=aext+wall,$fn=23);
        }
        translate([rkr1,-dr/2]) hull() {
            cylinder(d=dr,h=aext+wall,$fn=23);
            translate([0,-dr/2])cylinder(d=dr,h=aext+wall,$fn=23);
            translate([-dr/2,-dr])cylinder(d=dr,h=aext+wall,$fn=23);
        }
    }

    difference() { union() {f1(); rz(180) f1();} f00(); }
    f2(); difference() { rz(180) f2(); f0(); }
    f3(); 
    f4(); rz(180) f4();
    f5();
    f6();
}

module potplate()
{
    wall1=1;
    offs1=14.5;
    offs2=28.5;
    lck=2.5;
    h1=17;
    h2=30.5;
    w2=10;
    bol=[[-52/2+3.5,-wall-9.5],[52/2-3.5,-wall-13.5]];
    module f1() z(-wall) {
        translate([-51/2,-17-lck])cube([51,17,wall]);// main plate
        translate([-20/2,-wall-.5]) cube([20,wall+.5,wall]); // main lock
        let(v=w2+2*(h2-h1)) hull() { // main extender for trimmer
            translate([-w2/2,-h2-lck]) cube([w2,h2,wall]);
            translate([-v/2,-17-lck]) cube([v,17,wall]);
        }
        // main rocker spring wall && holder
        translate([-51/2+5.5,-9-17-lck+.01]){
            cube([11,9,wall]); 
            z(wall-.01) {
                cube([5.3,17,6]);
                translate([5.3-3.8,0])cube([3.8,12,9]);
            }
        }
        // main rocker support
        // ###FIXME diagonalize top of support
        // collision  with stand support on mountplate 
        translate([51/2-5-5,-17-lck+2])
            z(2.5-.01) cube([5,12,6.5]);
        // pot tube
        translate([0,-offs1,-7+wall]) cylinder(d=12,h=7,$fn=23);
         // trim brake
        translate([0,-offs2,-wall+.1])
            rz(90)ring(35,2*26+2*.2,2*26+2*1,wall,$fn=99);
        // refs
        translate([-52/2+3.5,-wall-2.5]) cylinder(d=2,h=wall+1,$fn=21);
        translate([52/2-3.5,-wall-5.5]) cylinder(d=2,h=wall+1,$fn=21);      
        // bolts
        for(j=bol) translate(j) cylinder(d=7,h=wall,$fn=21);
    }
    module f2() for(j=bol) translate(j) { // bolts
        cylinder(d=2.2,h=wall*3,center=true,$fn=21);
        z(-2-wall+1)cylinder(d=4.6,h=2.01,$fn=21);
        z(-wall+1)cylinder(d1=4.6,d2=2.2,h=1,$fn=21);
    }
    module f3() { // rocker mount
        // spring stopper carrage path
        translate([-51/2+5.5+5.3/2,-9-17-lck,11.5/2-2.5]) {
            cube([6,10*2,3.8],center=true);// main body path
            cube([2,10*2,7],center=true);// railings
            translate([-5.3,0,0])cube([5.3-2/2+.1,10,7]);// cut rest
            rx(90)z(-15)cylinder(d=2.2,h=15,$fn=15);// bolt path
        }
        // rocker axis
        // ###FIXME diagonalize top of support
        // collision  with stand support on mountplate 
        translate([51/2-5-5,-17-lck+2]) {
            translate([5/2-.2,0,6/2]) cube([5,11*2,3.2],center=true);
            hull() for(j=[0,3])
            translate([5/2,j,6/2])cylinder(d=1.9,h=7,center=true,$fn=19);
        }
    }

    difference() {
        f1();
        translate([0,-offs1,0]) cylinder(d=9,h=7*3,$fn=47,center=true); // pot
        translate([0,-offs2,0]) cylinder(d=4,h=wall*3,$fn=47,center=true);//pend
        f2();
        f3();
    }
}

///potplate();translate([0,-14.5,3]) rx(90)rockerarm();

module potnut() color([.5,.5,.5]){
    difference() {
        z(-1) union() {
            cylinder(d=11,h=1,$fn=30);
            cylinder(d=9,h=8.5,$fn=53);
        }
        z(-1) cube([12,1,1.6],center=true);
        cylinder(d=7,h=20,center=true); // thread
    }
}

//potcoupler();
module potcoupler() { // maybe two flat parts
    w=3;
    groove=2;
    gdiam=12+.1;
    pad=.5;
    difference() {
        hull() {
            cylinder(d=20,h=w,$fn=51); // base
            translate([-6/2,0,0])cube([6,17.5,w]); // base drive
        }
        z(-.1)cylinder(d=gdiam,h=groove+.1,$fn=53); // plate pin groove
        cylinder(d=7,h=w*3,center=true,$fn=23); // pot hole
        translate([-8,0])cylinder(d=2.9,h=w*3,center=true,$fn=12); // pot ref
        translate([0,0,w]) intersection() { // 0.5mm pad for potentiometr
            cube([18,11,2*pad],center=true);
            cylinder(d=18,h=2*pad,center=true);
        }
            
    }
    translate([0,10,-2.5+.01])cylinder(d=3,h=2.5,$fn=30); // drive pin
}


module pottrimmer() {
    wall=3; // horizontal wall 
    wallv=2; // vertical wall
    hi=8;  // overall part height
    da=30; // motion angle
    db=75; // detail angle
    dc=da+35; // limiter angle
    ds=55; // spring angle
    offs1=14.5; // pot center
    offs2=28.5; // this center, main pin
    offs3=24.5; // drivig center
    d2=8;  // main pin curvature
    rd=28.5; // part diameter
    ro=31.5; // outer part diameter
    dpin=4;  // main pin diameter
    ddrv=3;  // drive pin diameter
    dpot=13; // pin pot pass throung
    dapot=dpot+8; // ring around pinpot
    trimh=41.5;
    trimw=8;
    module f1() {
        z(-3+.01)cylinder(d=4,h=dpin,$fn=31); // pin
        hull() {
            cylinder(d=d2,h=wall,$fn=19); // base pin
            ring(a=db,d1=0,d2=2*rd,h=wall,$fn=99); // base
        }
        let(q=2*(offs2-offs1))rring(da,q-dapot,q+dapot,wall); // pin pot outer
        ring(a=db,d1=2*rd-wallv*2,d2=2*rd,h=hi,$fn=99); // wall
        z(hi-wall) {
            ring(a=db,d1=2*rd-wallv*2,d2=2*ro,h=wall,$fn=99);
            translate([offs2,-trimw/2])cube([trimh-offs2,trimw,wall]);
        }
    }
    module f2() {
        let(q=2*(offs2-offs1),ra=dpot)
            rring(da,q-ra,q+ra,wall*3,center=true,$fn=79); // pot pin path
        hull() for(k=[offs3,offs1]) translate([offs2-k,0])  // drive pin path
            cylinder(d=ddrv,h=wall*3,center=true,$fn=23);
        ring(dc,2*26,2*ro,hi-wall,$fn=81);
        rring(ds,2*23,2*23+2*2,wall*3,center=true,$fn=51);
    }

    rz(0){ // trim rotation test
        difference() { f1(); f2(); }
        translate([26,0])cylinder(d=0.5,h=wall,$fn=33);
    }
}

module rockerarm() {
    wall=2;
    wwall=3;
    hpin=5;
    dpin=1.8;
    h1=7;
    hook=2.5;
    module f1() {
        translate([-11.5-hook,-wall/2,-9.5])cube([24.01+hook,wall,9.5]);
        translate([-11.5,-wwall/2,-h1])cube([wwall,wwall,h1]);
        hull() {
            translate([ 12.5,-wwall/2,-h1])cube([wwall,wwall,h1]);
            translate([13.5+4.5,0])rx(90)cylinder(d=2+dpin,h=wwall,center=true,$fn=15);
        }
        translate([13.5+4.5,0])rx(90)cylinder(d=dpin,h=hpin,center=true,$fn=15);
    }
    module f2() {
        rx(90)cylinder(d=8,h=wwall,center=true,$fn=31);
        translate([-15,-wwall,-1+.01])cube([15,wwall*2,1.01]);
        translate([-11.5-hook/2,0,-1-hook]) hull() { // hook path
            rx(90)cylinder(d=dpin/2,h=wwall,center=true,$fn=31);
            for(t=[[-1,0,-dpin],[.5,0,-2.5],[-1,0,-8],[.5,0,-8]])translate(t)
                rx(90)cylinder(d=dpin,h=wwall*1.5,center=true,$fn=15);
        }
    }
    module f3() hull() {
        translate([2,0,25-9])
            rx(90)cylinder(r=25,h=hpin,center=true,$fn=60);
    }
    difference() {
        intersection() { f1(); f3(); }
        f2();
    }
}

module rockerhook() {
    w1=4-.1;
    w2=7-.2;
    d1=5-.2;
    d2=2-.2;
    h1=7.5;
    h2=2.5;
    w3=2;
    d3=6.5;
    p3=1;
    o3=5.0;
    difference() {
        union() {
          translate(-[d1,w1]/2) cube([d1,w1,h1]);
          translate(-[d2,w2]/2) cube([d2,w2,h1]);
          translate(-[0,w3]/2) cube([d3,w3,h2]);
        }
        translate([o3,0])cube([p3,w3*2,p3*2],center=true);
        z(-.01)cylinder(d=3.3,h=2,$fn=17);
        z(-.01)cylinder(d=1.8,h=h1+1,$fn=17);
    }
}

//pot();

module pot(leftside=false) // ###FIXME make a model
{
    translate([leftside?-9.5:9.5,-8.25,-9.5/2-3.5])
        cube([3.5,6.5,9.5],center=true); // connector
    translate([leftside?-1.5:1.5,-1.6/2-11.5,-10/2-3]) 
        cube([21,1.6,10],center=true);
    translate([-15/2,-11.5,-3])cube([15,11.5,1.2]); // pot pcb
    color([.5,.5,.5]) {
        z(-9)cylinder(d=17,h=7.2); // housing
        z(-1.8)cylinder(d=11,h=1.8);// mountbase
        translate([-17/2+1/2,0,.2])cube([1,2.8,4],center=true);
        cylinder(d=7,h=7); // thread
        difference() { // schaft
            cylinder(d=6,h=17);
            translate([-6/2,-6/2-4.5,13]) cube(6);
        }
    }
}

module potasm(leftside=false)
{
    potplate();
    translate([0,-14.5])ry(180)potnut();
    translate([0,-14.5])z(-8)pot(leftside);
    translate([0,-14.5,-7+2-.5])rx(180)potcoupler();
    translate([0,-28.5,-2.5])ry(180)rz(90)pottrimmer();
    translate([0,-14.5,3]) rx(90)rockerarm();
    translate([-51/2+8.1,-28.5,3.3])rx(-90) rockerhook();
}

module stick_rod(l=44)
{
    color([.5,.5,.5])cylinder(d=4,h=l);
    z(l-24)cylinder(d1=5.5,d2=7,h=9);
    z(l-15)cylinder(d=8,h=11.5);
    z(l-3.5)cylinder(d=7,h=3.5);
}

leftgimbal=true;
mntplate();

z(-14.5)stickA();
z(-14.5)stickB();
z(-14.5+6)stick_rod();

z(-14.5)xcap();
rz(180)translate([0,52/2,0]) rx(90) potasm(leftgimbal);
translate([0,52/2,0]) rx(90)sideplate();

rz(leftgimbal?0:180) {
z(-14.5)ydrum();
translate([-19,-18,-29.5]) spring1();
rz(90)translate([0,52/2,0]) rx(90)sideplate();
rz(-90)translate([0,52/2,0]) rx(90)potasm(!leftgimbal);
}
