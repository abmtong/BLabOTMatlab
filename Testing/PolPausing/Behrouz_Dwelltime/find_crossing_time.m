function [Tc_array]=find_crossing_time(t_array, x_array,Nw)

x=x_array(1);

x0=x+Nw;

xmax=max(x_array);

line_num_tot=floor(xmax/Nw);

Tc_array(1)=0;

line_num=2;

T=0;

while (x < xmax)
    
    T=T+1;
    
    x=x_array(T);
    
    t=t_array(T);
    
    if (x >= x0)
        
        %x0=x0+Nw;

        x0=x+Nw;
        
        Tc_array(line_num)=t;
        
        line_num=line_num+1;
        
    end
    
end

Tc_array=Tc_array(1:line_num-1);
