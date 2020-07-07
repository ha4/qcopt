$fn=60;
//step=5;cr1=25;cr2=15;
//r=5;w=5;
//l1=100;l2=50;
//cr11=10;

//
//r  bevel radius
//l1 cr1 cr11 - first tube cone
//l2 cr2 - second tube cylinder
//w - wall thickness
//step - number of steps in 0-90 degrees arc

module tritube(l1,cr1,cr11,l2,cr2,r,w,step=5){
    module j1(dr1=0,dh=0) translate([0,0,-dh])
        cylinder(r1=cr1+dr1,r2=cr1-cr11+dr1,h=l1+dh*2);
    module j2(dr2=0,dh=0)
        translate([0,0,l1/2])rotate(90,[1,0,0])
            cylinder(r=cr2+dr2,h=l2+dh);
    module j3(i) intersection() {
        j1(r-r*cos(i));
        j2(r-r*sin(i));
        }
    module bvl()
        for (i=[0:step:90-step]) hull(){ j3(i); j3(i+step); }

    difference(){
        union(){ j1(); j2(); bvl(); }
        union(){ j1(-w,0.1); j2(-w,0.1); }
    }
//    j3(0);    j3(30);    j3(60);    j3(90);
}

tritube(180,25,10,38,15,5,1,15);