function [Dis_BStoRIS, Dis_BStoUser, Dis_RIStoUser]=Position_generate(B,R,K,dist)
Dis_BStoRIS=zeros(B,R);
Dis_BStoUser=zeros(B,K);
Dis_RIStoUser=zeros(R,K);

hBS = 15;      % Altura estación base (m)
hRIS = 6;      % Altura RIS (m)
hUE = 1.5;     % Altura usuario (m)

% BS_position=zeros(B,2);
% BS_position(1,:)=[0 20];
% BS_position(2,:)=[0 -20];
% % BS_position(3,:)=[60 15];
% % BS_position(4,:)=[60 -15];
% 
% RIS_position=zeros(R,2);
% RIS_position(1,:)=[30 3];
% RIS_position(2,:)=[45 -3];
% % RIS_position(3,:)=[70 3];
% % RIS_position(4,:)=[80 -3];

BS_height=hBS; % Altura de BS
BS_position=zeros(B,2);
BS_position(1,:)=[60 -200];
BS_position(2,:)=[70 -200];
BS_position(3,:)=[80 -200];
BS_position(4,:)=[90 -200];
BS_position(5,:)=[100 -200];

RIS_height=hRIS; % Altura de RIS
RIS_position=zeros(R,2);
RIS_position(1,:)=[79 -1];
RIS_position(2,:)=[81 -1];

user_height=hUE;
user_position=repmat([dist 0],K,1); % Usuario fijo en (L,0)
for b=1:B
    for r=1:R
        BS_position_temp=reshape(BS_position(b,:),2,1);
        RIS_position_temp=reshape(RIS_position(r,:),2,1);
        Dis_BStoRIS(b,r)=sqrt(distance(BS_position_temp,RIS_position_temp)^2+(RIS_height-BS_height)^2);
    end
end

for b=1:B
    for k=1:K
        BS_position_temp=reshape(BS_position(b,:),2,1);
        user_position_temp=reshape(user_position(k,:),2,1);
        Dis_BStoUser(b,k)=sqrt(distance(BS_position_temp,user_position_temp)^2+(BS_height-user_height)^2);
    end
end

for r=1:R
    for k=1:K
        user_position_temp=reshape(user_position(k,:),2,1);
        RIS_position_temp=reshape(RIS_position(r,:),2,1);
        Dis_RIStoUser(r,k)=sqrt(distance(RIS_position_temp,user_position_temp)^2+(RIS_height-user_height)^2);
    end
end

end