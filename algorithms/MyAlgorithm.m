function [W,Theta,R_sum,R_k]=MyAlgorithm(B,BS_antennas,User_antennas,P_max,K,P,R,N_ris,sigma2,H_bkp,F_rkp,G_brp,W,Theta)

iteration=30;  % Máximo 30 vueltas del algoritmo
R_sum=zeros(2*iteration,1); % guarda 60 resultados --> el resultado anterior, y el actual por cada iteracion
R_k_all=zeros(K,2*iteration); % guarda tasas individuales por usuario en cada iteración
gamma_k=ones(K,1); % Pesos de usuarios (todos iguales) 
alpha_kp=ones(K,P); %variables auxiliares
beta_kp=ones(K,P); %variables auxiliares

% Theta_r=zeros(R,N_ris,N_ris);
% for r=1:1:R
%     temp=exp(1j*pi*(rand(N_ris,1)>0.5));
%     Theta_r(r,:,:)=diag(temp);
% end
% w_bpk=sqrt(P_max/K/P/BS_antennas/2)*(ones(B,P,K,BS_antennas)+1j*ones(B,P,K,BS_antennas));
% codigo que sirve para inciializar de forma totalmente aleatoria

[w_pk,w_bpk] = W2wbpk_and_wpk(P,K,B,BS_antennas,W); % dos matrices organizadas por subportadora (SNIR) o bien por estacion (restricciones de potencia)
% W -> matriz de precodificaci��n
% W inicial = Todos los elementos son 1+1j (neutral)
% Theta inicial = Fases aleatorias entre 0 y 2��

D_b=zeros(B,B*P*K*BS_antennas,B*P*K*BS_antennas);
for b=1:B
    temp=zeros(B,B);
    temp(b,b)=1;
    temp=kron(temp,eye(BS_antennas,BS_antennas));
    temp=kron(eye(P*K,P*K),temp);
    D_b(b,:,:)=temp;
end % Crea m��scaras para cada estaci��n base. Sirve para calcular la potencia de cada estaci��n por separado
% Theta= Theta_generate(R,N_ris,Theta_r);

w_pk = wbpk2wpk(P,K,B,BS_antennas,w_bpk); %organiza por subportadora

[F_kp,G_bp] = F_kp_and_G_bp_generate(B,K,P,R,N_ris,BS_antennas,User_antennas,F_rkp,G_brp); % reorganiza de (B,R,P,N_ris,BS_antennas) a formato (B,P,RN_ris,BS_antennas)
% F_kp -> RIS �� Usuario
% G_bp -> Estaci��n �� RIS

for Q=1:iteration
%% Calcula el canal efectivo total = canal directo + canal no directo
h_kp= h_kp_generate(B,K,R,P,N_ris,BS_antennas,User_antennas,H_bkp,Theta,G_bp,F_kp);


%%  Calcula el rendimiento del sistema y verifica si ya convergi��
[SINR_kp,R_sum(2*Q-1),R_k_all(:,2*Q-1)] = SINR_generate(K,P,B,BS_antennas,User_antennas,h_kp,w_pk,sigma2); %SINR = Señal_útil / (Interferencia + Ruido)
%R_sum es la velocidad del usuario
if Q>1 %(apartir de la 2 iteracion)
    if (R_sum(2*Q-1)-R_sum(2*Q-3))/R_sum(2*Q-2)<0.01   %considera que ha convergido cuando es porcentage de mejora es menor a 0.01
       break; 
    end
end

% AAA=R_sum(Q)
%%  alpha����
alpha_kp=SINR_kp;
alpha_hat_kp=diag(gamma_k)*(1+alpha_kp);          %��������alpha_hat
%%  beta����
beta_kp = beta_kp_update(K,P,B,BS_antennas,User_antennas,alpha_hat_kp,h_kp,w_pk,sigma2);
%%  V����
V= V_generate(P,K,B,BS_antennas,User_antennas,alpha_hat_kp,beta_kp,h_kp);
%%  W ����
W = wpk2W(P,K,B,BS_antennas,w_pk);
% BBB=W'*W
%% A ��������
A = A_generate(P,K,B,BS_antennas,User_antennas,beta_kp,h_kp);
%%  �Ż�W
[W,P_b]= cvx_solve_W(A,V,W,D_b,P_max);
%%  ͬ������w
[w_pk,w_bpk] = W2wbpk_and_wpk(P,K,B,BS_antennas,W);
[SINR_kp,R_sum(2*Q),R_k_all(:,2*Q)] = SINR_generate(K,P,B,BS_antennas,User_antennas,h_kp,w_pk,sigma2);
%%  �Խ���ת����
theta=Theta*ones(R*N_ris,1);
%%  ���� b �� a
[b_kpj,a_pj] = apj_and_bkp_generate(K,P,R,B,N_ris,BS_antennas,User_antennas,w_bpk,H_bkp,G_bp);
%%  eps����
eps_kp = beta_kp_update(K,P,B,BS_antennas,User_antennas,alpha_hat_kp,h_kp,w_pk,sigma2);
[c_kpj,g_kpj] = ckpj_and_gkpj_generate(K,P,R,N_ris,User_antennas,F_kp,b_kpj,a_pj,eps_kp);
%%  ����U V
[U,v] = U_v_generate(K,P,R,N_ris,alpha_hat_kp,c_kpj,g_kpj);
%% �Ż�theta
theta=cvx_solve_Theta(R*N_ris,U,v,theta);
Theta=diag(theta);  %��Խ��󱣳�һ��
end
% plot(abs(R_sum));
[R_sum,best_idx]=max(R_sum);
R_k=R_k_all(:,best_idx);  % Tasas individuales correspondientes al mejor R_sum
end