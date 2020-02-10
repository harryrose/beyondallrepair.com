size(500);
int rad = 200;


defaultpen(1.5 + fontsize(18));

pair origin = (0,0);

pair p1 = (0, rad);
pair p2 = (rad * Sin(120), rad * Cos(120));
pair p3 = (rad * Sin(240), rad * Cos(240));

pair angleLabelPosition = (rad * Sin(60) / 5, rad * Cos(60) / 5);

draw((-1,0)--(1,0));
draw((0,-1)--(0,1));

draw(origin -- p1,dashed);
draw(origin -- p2,dashed);
draw(origin -- p3,dashed);


draw(p1--p2,blue);
draw(p2--p3,blue);
draw(p3--p1,blue);
draw(circle((0,0),rad));

draw(arc(origin, p2/5, p1/5));
label("$120^\circ$",angleLabelPosition,E);
label("$r_b$", p1 / 2,E);
label("$l_e$", p1--p2,NE);

pen p = currentpen + red;

dot(p1,p);
dot(p2,p);
dot(p3,p);
label("$(0,r_b)$", p1,N, Fill(white+opacity(0.7)));
label("$(r_b \cdot \mathrm{sin}(120), r_b \cdot \mathrm{cos}(120))$",p2,S,Fill(white+opacity(0.7)));
label("$(r_b \cdot \mathrm{sin}(240), r_b \cdot \mathrm{cos}(240))$",p3,S,Fill(white+opacity(0.7)));

shipout(bbox(white, Fill));
