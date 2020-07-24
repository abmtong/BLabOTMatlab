% Example Code for Printing Progress to the Command Window
fprintf(1,'here''s my integer:  ');
for i=1:9
     fprintf(1,'\b%d',i); 
     pause(.1);
end
fprintf('\n')