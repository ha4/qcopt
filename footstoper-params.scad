function bin(n,k=0) = (k==0)?1:(n-k+1)/k*bin(n,k-1);
function p_bern(t,n)=let(r=1-t)
    [for(i=[0:n]) bin(n,i)*pow(r,(n-i))*pow(t,i)];
function bezier(t,pts)=p_bern(t,len(pts)-1)*pts;
function curvepts(pb,n=20)=[for (t=[0:n]) bezier(t/n,pb)];
function circular(r,ofs,a1=0,a2=360)=let(n=$fn, da=(a2-a1)/n) [for(a=[a1:da:a2]) ofs+r*[cos(a),sin(a)]];
module poly1(w,c)
{
    curvofset=7; ofs=20;
    Z=20; skew=20; tr=11; Dtr=2.5;
    
    v1=[[-w/2,0],[0,c],[w/2,0]];
    v2=[[w/2,ofs],[0,c+ofs+curvofset],[-w/2,ofs]];
    pa=[0,skew];
    p0=bezier(0.5,v1);
    p1=curvepts(v1);
    p1x=curvepts(v1,n=tr-1);
    c1=circular(r=ofs/2, ofs=[w/2,ofs/2], a1=270+20,a2=450-20,$fn=8);
    p2=curvepts(v2);
    c2=circular(r=ofs/2, ofs=[-w/2,ofs/2], a1=90+20,a2=270-20,$fn=8);
    
        translate(-p0) 
    translate(-pa)
        linear_extrude(height=Z,scale=[1,1-.1])
    translate(pa)difference() {
            polygon( points=concat(p1,c1,p2,c2), convexity=3);
        for(c=p1x) translate(c-p0) circle(d=Dtr,$fn=20);
        }
}

poly1(40,0);
