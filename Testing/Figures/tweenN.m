function tweenN()
res = 200; %pts per sphere

[spx, spy, spz] = sphere(res); 
sp = {spx spy spz}; %so we can use surface(sp{:}) as shorthand
