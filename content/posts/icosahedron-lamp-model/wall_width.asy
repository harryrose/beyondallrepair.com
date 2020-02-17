import graph;
size(500);
int rad = 200;

real cropFrac = 1/2;
defaultpen(1.5 + fontsize(18));

pair origin = (0,0);

pair p1 = (0, rad);
pair p2 = (rad * Sin(120), rad * Cos(120));
pair p3 = (rad * Sin(240), rad * Cos(240));
pair p2p3mid = (p2 + p3) / 2;


pair angleLabelPosition = (rad * Sin(60) / 5, rad * Cos(60) / 5);

draw(origin -- p2,solid);
draw(origin -- p2p3mid, solid);

pen smallerStyleHi = red+dashed+3;
pen smallerStyleNorm = dashed+grey;
real smallerFrac = 2/3;

draw(p1--p2,blue);
draw(p2--p3,blue);
draw(p3--p1,blue);

pair p1smaller = p1*smallerFrac;
pair p2smaller = p2*smallerFrac;
pair p2p3midsmaller = p2p3mid*smallerFrac;
pair p3smaller = p3*smallerFrac;

draw(origin--p2smaller, smallerStyleHi);
draw(origin--p2p3midsmaller, smallerStyleHi);
draw(p2p3midsmaller-- p2smaller, smallerStyleHi);
draw(p2p3midsmaller -- p3smaller, smallerStyleNorm);
draw(p3smaller -- p1smaller, smallerStyleNorm);
draw(p1smaller -- p2smaller, smallerStyleNorm);

draw(circle((0,0),rad));

path h_br = brace(p2p3mid, origin);
draw(h_br);

path rb_br = brace(origin,p2);
draw(rb_br);
label("$r_b$", midpoint(rb_br),NE);
label("$r_b'$", p2smaller/2, SW,red);

label("$h$", midpoint(h_br),W);
label("$w$", p2p3mid * (1 + smallerFrac) / 2,E);
pen p = currentpen + red;

dot(p1,p);
dot(p2,p);
dot(p3,p);


xlimits(-rad * cropFrac,rad,Crop);
ylimits(-rad,rad * cropFrac,Crop);

shipout(bbox(white, Fill));
