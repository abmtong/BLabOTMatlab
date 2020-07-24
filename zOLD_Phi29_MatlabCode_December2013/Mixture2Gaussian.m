function [] = Mixture2Gaussian(x)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
 Prompt = {'a1','b1','c1','a2','b2','c2'};
 Title = 'Enter paremeter values';Lines =1;   
 Default={'0.1','1','1','0.1','1','1'};
 answer = inputdlg(Prompt,Title,Lines,Default);
    a1=str2num(answer{1});
    b1=str2num(answer{2});
    c1=str2num(answer{3});
    a2=str2num(answer{4});
    b2=str2num(answer{5});
    c2=str2num(answer{6});
    
    

for i=1:length(x)
func(i)=a1*exp(-((x(i)-b1)./c1)^2)+a2*exp(-((x(i)-b2)./c2)^2);
g1(i)=a1*exp(-((x(i)-b1)./c1)^2);
g2(i)=a2*exp(-((x(i)-b2)./c2)^2);
end

Q1=trapz(x,g1);
Q2=trapz(x,g2);
QT=trapz(x,func);
P1=Q1/QT;
P2=Q2/QT;

disp(P1);
disp(P2);

figure;
plot(x,func);
hold on;  plot(x,g1,'Color',[0.8,0.87,0.95]);plot(x,g2,'Color',[0.8,0.87,0.95]);
area(x,g1,'FaceColor',[0.8,0.87,0.95])
area(x,g2,'FaceColor',[0.8,0.87,0.95])
end

