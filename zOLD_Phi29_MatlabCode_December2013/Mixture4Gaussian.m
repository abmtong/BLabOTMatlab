function [] = MixtureGaussian(x,a1,a2,a3,a4,b1,b2,b3,b4,c1,c2,c3,c4)
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here

Prompt = {'a1','b1','c1','a2','b2','c2','a3','b3','c3','a4','b4','c4'};
 Title = 'Enter paremeter values';Lines =1;   
 Default={'0.1','1','1','0.1','1','1','0.1','1','1','0.1','1','1'};
 answer = inputdlg(Prompt,Title,Lines,Default);
    a1=str2num(answer{1});
    b1=str2num(answer{2});
    c1=str2num(answer{3});
    a2=str2num(answer{4});
    b2=str2num(answer{5});
    c2=str2num(answer{6});
    a3=str2num(answer{7});
    b3=str2num(answer{8});
    c3=str2num(answer{9});
    a4=str2num(answer{10});
    b4=str2num(answer{11});
    c4=str2num(answer{12});



for i=1:length(x)
func(i)=a1*exp(-((x(i)-b1)./c1)^2)+a2*exp(-((x(i)-b2)./c2)^2)+a3*exp(-((x(i)-b3)./c3)^2)+a4*exp(-((x(i)-b4)./c4)^2);
g1(i)=a1*exp(-((x(i)-b1)./c1)^2);
g2(i)=a2*exp(-((x(i)-b2)./c2)^2);
g3(i)=a3*exp(-((x(i)-b3)./c3)^2);
g4(i)=a4*exp(-((x(i)-b4)./c4)^2);
end

Q1=trapz(x,g1);
Q2=trapz(x,g2);
Q3=trapz(x,g3);
Q4=trapz(x,g4);
QT=trapz(x,func);
P1=Q1/QT;
P2=Q2/QT;
P3=Q3/QT;
P4=Q4/QT;

disp(P1);
disp(P2);
disp(P3);
disp(P4);


figure;
plot(x,func);
hold on;  plot(x,g1,'Color',[0.8,0.87,0.95]);plot(x,g2,'Color',[0.8,0.87,0.95]);plot(x,g3,'Color',[0.8,0.87,0.95]);
plot(x,g4,'Color',[0.8,0.87,0.95]);
area(x,g1,'FaceColor',[0.8,0.87,0.95])
area(x,g2,'FaceColor',[0.8,0.87,0.95])
area(x,g3,'FaceColor',[0.8,0.87,0.95])
area(x,g4,'FaceColor',[0.8,0.87,0.95])
end

