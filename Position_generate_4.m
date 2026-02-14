function [Dis_BStoRIS, Dis_BStoUser, Dis_RIStoUser]=Position_generate_4(B,R,K,dist)
Dis_BStoRIS=zeros(B,R);
Dis_BStoUser=zeros(B,K);
Dis_RIStoUser=zeros(R,K);

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

BS_height=3; %2
BS_position=zeros(B,2);
BS_position(1,:)=[0 -50];
BS_position(2,:)=[40 -50];
BS_position(3,:)=[80 -50];
BS_position(4,:)=[120 -50];
BS_position(5,:)=[160 -50];

BS_position(6,:)=[10 -40];
BS_position(7,:)=[30 -40];
BS_position(8,:)=[50 -40];
BS_position(9,:)=[70 -40];
% BS_position(3,:)=[60 15];
% BS_position(4,:)=[60 -15];

RIS_height=6; %6
RIS_position=zeros(R,2);
% RIS_position(1,:)=[60 10];
% RIS_position(2,:)=[100 10];
RIS_position(1,:)=[20 10];
RIS_position(2,:)=[40 10];
RIS_position(3,:)=[60 10];
RIS_position(4,:)=[80 10];
RIS_position(5,:)=[100 10];
RIS_position(6,:)=[120 10];
RIS_position(7,:)=[140 10];
%RIS_position(8,:)=[160 10];


% RIS_position(3,:)=[70 3];
% RIS_position(4,:)=[80 -3];

angle1=2*pi*rand();
angle2=2*pi*rand();
angle3=2*pi*rand();
angle4=2*pi*rand();

amplituede1=rand();
amplituede2=rand();
amplituede3=rand();
amplituede4=rand();

Radio=1;

user_height=1.5;
user_position=zeros(K,2);

% user_position(1,:)=[dist+Radio*amplituede1*cos(angle1) Radio*amplituede1*cos(angle1)];
% user_position(2,:)=[dist+Radio*amplituede2*cos(angle2) Radio*amplituede2*cos(angle2)];
% user_position(3,:)=[dist+Radio*amplituede3*cos(angle3) Radio*amplituede3*cos(angle3)];
% user_position(4,:)=[dist+Radio*amplituede4*cos(angle4) Radio*amplituede4*cos(angle4)];
user_position(1,:)=[dist-60 0];
user_position(2,:)=[dist-20 0];
user_position(3,:)=[dist+20 0];
user_position(4,:)=[dist+60 0];
% user_position(1,:)=[dist 0];
% user_position(2,:)=[dist 0];
% user_position(3,:)=[dist 0];
% user_position(4,:)=[dist 0];
% user_position(5,:)=[dist+4*(rand()-0.5) 4*(rand()-0.5)];
% user_position(6,:)=[dist+4*(rand()-0.5) 4*(rand()-0.5)];
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