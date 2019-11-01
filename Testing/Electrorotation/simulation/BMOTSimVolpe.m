function BMOTSimVolpe(np)
% Trajectory Generator for a Spherical Particle in an Optical Trap %
%       Written by Joseph Glaser, Cleveland State University       %
%                       Department of Physics                      %
%                      Version 1.0.0 (11/06/13)                    %

%Begin UI %
T= input('Enter the Time Period: ');            % Time (in Seconds)
R= input('Enter Sampling Rate: ');              % Rate (in Hertz)
r= input('Enter the Radius: ');                 % Radius (in Meters)                
%End UI%

% Begin Constants %
N=R*T;                                      % Number of Impulses
den=1000;                                   % Density of Sphere (kg/m^3)
kv=(1e-6);                                  % Kinematic Viscosity (m^2/s)
M=(4*pi*r^3*den)/3;                         % Mass of Sphere (kg)
gamma=(6*pi*den*kv*r);                      % Drag Coefficient (kg/s)
delta=1/R;                                  % Time Between Jumps (Seconds)
kx=2.1e-5;                                  % Trap X-Axis Strength (N/m)
ky=2.1e-5;                                  % Trap Y-Axis Strength (N/m)
kz=1e-5;                                    % Trap Z-Axis Strength (N/m)
kB=1.380648813e-23;                         % Boltzman Constant (J/K)
T=300;                                      % Room Temperature (K)
D=kB*T/gamma;                               % Diffusion Const (m^2/s)
% End Constants %

if nargin < 1
    np = 1;
end

% Begin Setting All Particles to Initial Conditions %
x = zeros(1,np);                            % Setting (X,Y,Z)=(0,0,0)
y = zeros(1,np);
z = zeros(1,np);
wx = zeros(1,np);                           % Setting (Wx,Wy,Wz)=(0,0,0)
wy = zeros(1,np);
wz = zeros(1,np);
% End Setting All Particles to Initial Conditions %

% Begin Iteration & Storage of Random Numbers, Velocities, & Positions %
fprintf('\n Simulation has begun ... \n');
for j=1:np
    for i=1:N
        
        %Each is ghetto randn(1)*11/12
        wx(i,j)=sum(rand(11,1)-0.5);
        wy(i,j)=sum(rand(11,1)-0.5);
        wz(i,j)=sum(rand(11,1)-0.5);
        
        x(i+1,j)=x(i,j)*(1-(kx*delta/gamma))+wx(i,j)*(sqrt(2*D*delta));
        y(i+1,j)=y(i,j)*(1-(ky*delta/gamma))+wy(i,j)*(sqrt(2*D*delta));
        z(i+1,j)=z(i,j)*(1-(kz*delta/gamma))+wz(i,j)*(sqrt(2*D*delta));
    end
end
fprintf(' Simulation is Complete! \n');
% End Interation & Storage of Random Numbers, Velocities, & Positions %

% Begin Saving of Data to Text Files %
fprintf(' Saving Data ... \n');

save('trajectory.mat','x','y','z');
save('randnum.mat','wx','wy','wz');

fprintf(' Data Saved Successfully! \n');
%End Saving of Data to Text Files %

% Begin K Effective Calculation %
kxe=kB*T/var(x);
kye=kB*T/var(y);
kze=kB*T/var(z);

fprintf(' Effective Spring Constants: \n');
fprintf('   X-Axis (N/m) = %e.\n',kxe);
fprintf('   Y-Axis (N/m) = %e.\n',kye);
fprintf('   Z-Axis (N/m) = %e.\n',kze);
% End K Effective Calculation %

% Begin Plotting Particle Trajectories % 
cmap = hsv(np); % Creates a np-by-3 set of colors from the HSV colormap

for K=1:np
    plot3(x(1:5000,K),y(1:5000,K),z(1:5000,K),'Color',cmap(K,:));
    hold on;
end
grid on;
% End Plotting Particle Trajectories %