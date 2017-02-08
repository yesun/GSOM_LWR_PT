function plot_cgarz_fval_ngsim
clear;
load CGARZ_varyingIC-realistic_rhom0_fval-ngsim.mat
beta = [.001,.01,.03,.05,.1,.3,.5,0.9,0.99];


load detector_data.dat 
%\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\\
% Deal with the data, find out Vol, and rho.
%////////////////////////////////////////////
B = detector_data;
% Pick the sensor station closest to the NGSIM study area, this is S#7
% i = 7;                         % study sensor station #7
% pick data from sensor #7 and sensor #8
A_indx = find(B(:,1)>6);      % ith detector
% % A_indx = find(B(:,1)==8);      % ith detector
% 
A = B(A_indx,:);
[vol, rho] = flow_density(A);  % find volume and density data
% [vol, rho] = flow_density(B);  % find volume and density data

% remove all NAN
indx = find(~isnan(rho));
density = rho(indx)';                % density data/sensor
flux = vol(indx)';                % flux data/sensor
q_max = max(max(flux));           % ???
figure(1)
P_sort=sortrows(P,29);
rho_m=P_sort(1,22);

grid = 0:rho_m;    % plot of the sequence of flow-density curves
plot(density,flux,'.','color',[0.2,0.2,0.2],'markersize',6), hold on
rho0 = 82; uf = 66.9088;  rhof = 934.7414;
v0 = diff_fd_free(rho0,uf,rhof);
f0 = fd_free(rho0,uf,rhof);

para=zeros(9,2);

for i =1:9
    P_sort=sortrows(P,22+i);
    para(i,1)=P_sort(1,(i-1)*2+1);
    para(i,2)=P_sort(1,(i-1)*2+2);
    if i~=7
        plot(grid,func_fd_seibold_2p(grid,P_sort(1,(i-1)*2+1),P_sort(1,(i-1)*2+2),rho0,v0,f0,uf,rhof,rho_m),'b-','linewidth',2.5),hold on
    else
        plot(grid,func_fd_seibold_2p(grid,P_sort(1,(i-1)*2+1),P_sort(1,(i-1)*2+2),rho0,v0,f0,uf,rhof,rho_m),'m-','linewidth',2.5),hold on
    end
    
end
hold off
para

test=1;
for i=i:length(grid)-1
    for j=1:8
        if func_fd_seibold_2p(i,para(j,1),para(j,2),rho0,v0,f0,uf,rhof,rho_m)>=func_fd_seibold_2p(i,para(j+1,1),para(j+1,2),rho0,v0,f0,uf,rhof,rho_m)
            test=test*1;
        else
            i
            j
            test=test*0;
        end
    end
end
test
rho_m
para

% for iter =1:10;
%     scatter3(iter,iter,iter),hold on;
% end
% hold off

%         xlabel('initial condition index','fontsize',14);
%         ylabel('\rho_{max}','fontsize',14);
%         strt = ['Parameter-GARZ-rhom ',' \beta = ',num2str(beta(i)),' count=',num2str(count),'/',num2str(882)];
%         strts = ['Parameter-GARZ-rhom-log',num2str(i),'.fig'];
%         title(strt,'fontsize',14);

function y = fd_free(rho,uf,rhof)  % quadratic form

y = uf*rho.*(1-rho/rhof);

function y = diff_fd_free(rho,uf,rhof)

y = uf*(1-2*rho/rhof);

function [Vol, rho] = flow_density(A) % find average velocity and volum

%=========================================
%     Volume over all lanes/30 seconds
%=========================================
Vol = A(:,34)+A(:,35)+A(:,36)+A(:,37)+A(:,38);   % # of cars/30 seconds
% Vol = A(:,29)+A(:,30)+A(:,31)+A(:,32)+A(:,33);   % # of cars/30 seconds

% change unit to # of cars/hour
Vol = 120*Vol;
%======================================
%     Average velocity/30 seconds
%======================================
Vel = A(:,8:5:28);         % store all the velocity in differents lanes
Nv = zeros(size(A(:,1)));  % nonzero velocity
v = zeros(size(A(:,1)));   % velocity vector
for i = 1:length(A(:,1))   % loop over all the rows
    indx = find(Vel(i,:)); % find index of nonzero velociy
    Nv(i) = length(indx);  % # of nonzero velocity
    v(i) = sum(Vel(i,:));
end

V = v./Nv;     % feet/second
% change unit  % km/hour
V = 1.09728*V;
rho = Vol./V;




