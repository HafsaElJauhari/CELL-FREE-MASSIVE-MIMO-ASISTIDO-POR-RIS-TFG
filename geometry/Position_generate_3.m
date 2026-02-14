function [Dis_BStoRIS, Dis_BStoUser, Dis_RIStoUser]=Position_generate_3(B,R,K,dist)
Dis_BStoRIS=zeros(B,R);
Dis_BStoUser=zeros(B,K);
Dis_RIStoUser=zeros(R,K);

BS_height=0; %2
BS_position=zeros(B,2);
BS_position(1,:)=[-1 0];

RIS_height=0; %6
RIS_position=zeros(R,2);
RIS_position(1,:)=[51 0];

user_height=0;
user_position=zeros(K,2);

user_position(1,1)=[dist];

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