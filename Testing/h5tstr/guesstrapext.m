function out = guesstrapext(ex1, f1x, f1y, ex2, f2x, f2y, cal)


out = hypot(f1x/cal.x1.k, f1y/cal.y1.k)/1000 + ex1 - ex2 + hypot(f2x/cal.x2.k, f2y/cal.y2.k)/1000;



