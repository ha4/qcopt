
rkrparam0=[31,7,8,20,3.0];// 0size,1width,2spring,3axle,4scalefactor
rkrparam=concat(rkrparam0,
    [1, //5pin lift
    -rkrparam0[3]/(rkrparam0[4]+1), // 6near pin offset
    rkrparam0[3]/(rkrparam0[4]-1)]); // 7far pin offset

module rotary6(tol=0,hh=6.5) let(flatspot=1.5)
intersection() {
    cylinder(d=6+tol,h=hh,$fn=32);
    translate([flatspot,0,0])cube([6+tol,6+tol,hh*3],center=true);
}
    
module rv09()
{
    cylinder(d=6.5,h=0.5,$fn=30);
    color([.2,.2,.2]) rotary6();
    translate([-9.8/2,-6.5,-5])cube([9.8,12,5]);
    translate([0,-6.5,-3.5])
    for(x=[-2.5,0,2.5]) translate([x,0,0])
        rotate([90,0,0])
        cylinder(d=.5,h=3.5);
}

module center()
{
    da=2;
    dam=4.5;
    db=3.0;
    dbm=6;
    dp=6; // use rotary6
    hm=12;
    do=15;
    ao=20;
    dm=9;
    hh=2;
    hs=6;
    
    module cylseg(d,h) intersection() {
        rotate([0,0,45])cube([d,d,h]);
        cylinder(d=d,h=h,$fn=60);
    }
    
    module cylstick()
        translate([0,0,hs])
            rotate([-90,0,0])
            cylinder(d1=do/2,d2=dbm,h=do/2+1,$fn=40);

    module mainparts() {
    hull() {
        cylinder(d=dm,h=hm,$fn=50);
        translate([rkrparam[6],rkrparam[5]])
            cylinder(d=dam,h=hm,$fn=30);
        rotate([0,0,ao])cylseg(d=do,h=hm);
    }
    translate([rkrparam[7],rkrparam[5]])
        cylinder(d=dam,h=hm,$fn=30);
    
    hull() {for(t=[[0,0],[rkrparam[7],rkrparam[5]]])
        translate(t) cylinder(d=dam-da,h=hm);
    }
    cylstick();
    linear_extrude(height=hs) projection()cylstick();
    }

    module baseplate()
    hull() { 
        cylinder(d=dm,h=hh,$fn=50);
        translate([rkrparam[7],rkrparam[5]])
            cylinder(d=dam,h=hh,$fn=30);
        rotate([0,0,ao])cylseg(d=do,h=hh);
    }
    difference() {
        union() {mainparts(); baseplate();}
        for(t=[[0,0],[rkrparam[7],rkrparam[5]],[rkrparam[6],rkrparam[5]]])
            translate(t) cylinder(d=da,h=hm*3,center=true,$fn=30);
        translate([0,0,6.51])rotate([0,0,90])rotary6(tol=0.2);
        translate([0,dm/2,hs])
            rotate([-90,0,0]) cylinder(d=db,h=do,$fn=30);
    }
    ///translate([0,0,5.51])rotate([0,0,90])rotary6();
}


module xrocker(ssy=0)
{
    da=2.0;
    dm=4.5;
    hm=3;
    hh=2;
    wid=rkrparam[1];
    sz=rkrparam[0];
    axis=rkrparam[3];
    ssx=rkrparam[2];
            ty=wid-dm/2-da/2;
            tx=(dm-da)/2;
    difference() {
    union() {
        cylinder(d=dm,h=hm,$fn=30);
        translate([ssx,-ty+ssy]) {
            cylinder(d=dm,h=hm,$fn=30);
            translate([-dm/2,0]) cube([dm,wid-dm/2-da/2-ssy,hh]);
        }
        hull() {
            cylinder(d=dm,h=hh,$fn=30);
            for(t=[[-tx,-ty],[ssx-da,tx],[ssx,-ty],[axis,-ty]])
              translate(t)cylinder(d=da,h=hh,$fn=30);
        }
        hull()
        for(t=[[ssx,-da/2],[sz,-da/2],[axis,-ty],[sz,-da]])
           translate(t)cylinder(d=da,h=hh,$fn=30);
    //translate([0,-wid+dm/2,0])cube([sz,wid-dm/2,hh]);
    }
    for(t=[[0,0],[ssx,-ty+ssy]])
        translate(t)
            cylinder(d=da,h=hm*3,center=true,$fn=40);
    translate([axis,0,0])
        cylinder(d=dm/1.5,h=hm*3,center=true,$fn=40);
    }
}

module xmount()
{
    wall=2;
    w=30;
    ew=9;
    h=10;
    dep=21;
    module clamp()
        hull() {
            ofs=3;zofs=wall*2;
            xsz=3;
            ysz=4;
            translate([0,-ysz/2,0])cube([xsz,ysz,wall]);
            translate([ofs,-ysz/2,zofs])cube([xsz,ysz,wall]);
        }
    module upper() {
        translate([-h/2,-w/2-ew,dep-wall])cube([h,w+ew,wall]);
        translate([h/2-4,-rkrparam[3]+rkrparam[2],0])
        translate([0,0,dep])rotate([180,0,0])clamp();
    }
    module base() {
        translate([-h/2,-w/2-ew,0])cube([h,w+ew,wall]);
        translate([-h/2,w/2-.01,0])cube([h,wall,dep]);
        translate([h/2-4,-rkrparam[3]+rkrparam[2],0]) clamp();
    }
    base();
    #upper();
    
    //#translate([-h/2,-w/2-ew,0]) cube([h,w+2*ew,dep]);
    
}

//xmount();

module xcap()
{
}

module ymount()
{
}

module yrocker()
{
}

module axle(l=10)
    color([0.6,.6,.6]) cylinder(d=2,h=l,$fn=40);
module stick()
    color([0.6,.6,.6]) cylinder(d=3,h=35,$fn=40);

module stickcap()
color([0.2,.2,.2]) difference() {
    union() {
    cylinder(d1=3.5,d2=6.5,h=10.01,$fn=40);
    translate([0,0,10])cylinder(d=6.5,h=6,$fn=40);
    }
    cylinder(d=3.2,h=15*2,center=true,$fn=50);
}

module assembly_stk(a2=0)
{
    translate([-6,0,0])
        rotate([90,0,90])center();
    translate([0,0,6]) {
        stick();
        translate([0,0,35-15])stickcap();
        }
    
    translate([-6-6.5,0,0])
        rotate([0,90,0])axle(13);
    translate([-6-3,rkrparam[6],rkrparam[5]])
        rotate([0,90,0])axle(15);
    translate([-6-3,rkrparam[7],rkrparam[5]])
        rotate([0,90,0])axle(15);

    
    rotate([-a2,0,0])translate([-8.5,-rkrparam[3],0])
    rotate([90,0,90])
    rotate([0,0,-abs(a2/rkrparam[4])]) {
        color("red")xrocker();
        translate([0,0,-4])axle(22);
        translate([rkrparam[2],-(rkrparam[1]-4.5/2)+rkrparam[5],0])
            axle(13);
    }
}

module assembly_x(a1=0) {
    rotate([a1,0,0]) assembly_stk(a1);
    translate([9,0,0]) rotate([0,-90,0])xmount();
}

//assembly_x();

module rockertest()
{
    a=30*sin($t*360);
    assembly_x(a);
}

rockertest();
