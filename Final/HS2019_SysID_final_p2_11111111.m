function [p2_a_ex1, p2_b_ex1,p2_a_ex2, p2_b_ex2, p2_mse_ex1, p2_mse_ex2] = HS2019_SysID_final_p2_11111111()
%% Solution for Problem 1

%% Generate data

% Extract Legi from Filename
name=mfilename;
LegiNumber= name(end-7:end);

% generate data
[p2_u1,p2_u2,p2_u_cv,p2_y1,p2_y2,p2_y_cv] = HS2019_SysID_final_p2_GenerateData(LegiNumber);

%% General instructions for solution

% Change the filename of this function, both in the function definition
% above and in the filename in the folder

% Use the variables p2_y and p2_u to solve the problem. 

% Modify your code in the next sections, and return the variables
% requested.

% If you skip one part of the problem, return the empty vectors as already
% provided in the code

disp('************************************************************')
disp('**                       Problem 2                        **')
disp('**                 --------------------                   **')
disp('************************************************************')

%% Part 1
mytext=sprintf('\n\n\nPart 1\n');
disp(mytext)

% regressor of data 1
N1 = length(p2_u1);
phi1 = zeros(N1, 5);
phi1(1,:) = [0 0 0 0 0];
phi1(2,:) = [-p2_y1(1) 0 0 p2_u1(1) 0];
phi1(3,:) = [-p2_y1(2) -p2_y1(1) 0 p2_u1(2) p2_u1(1)];
for i = 4:N1
    phi1(i,:) = [-p2_y1(i-1) -p2_y1(i-2) -p2_y1(i-3) p2_u1(i-1) p2_u1(i-2)];
end
% LS estimate from data 1
theta_est_ls = (phi1'*phi1)\(phi1'*p2_y1);

% System estimated from LS
A_ls = [1 theta_est_ls(1) theta_est_ls(2) theta_est_ls(3)];
B_ls = [0 theta_est_ls(4) theta_est_ls(5) 0];
G_ls = tf(B_ls, A_ls, -1, 'Variable', 'z^-1');

% regressor of data 2
N2 = length(p2_u2);
phi2 = zeros(N2, 5);
phi2(1,:) = [0 0 0 0 0];
phi2(2,:) = [-p2_y2(1) 0 0 p2_u2(1) 0];
phi2(3,:) = [-p2_y2(2) -p2_y2(1) 0 p2_u2(2) p2_u2(1)];
for i = 4:N2
    phi2(i,:) = [-p2_y2(i-1) -p2_y2(i-2) -p2_y2(i-3) p2_u2(i-1) p2_u2(i-2)];
end

% X-U IV of data 2
p2_x2 = lsim(G_ls, p2_u2);
zeta2_xu = zeros(N2, 5);
zeta2_xu(1,:) = [0 0 0 0 0];
zeta2_xu(2,:) = [-p2_x2(1) 0 0 p2_u2(1) 0];
zeta2_xu(3,:) = [-p2_x2(2) -p2_x2(1) 0 p2_u2(2) p2_u2(1)];
for i = 4:N2
    zeta2_xu(i,:) = [-p2_x2(i-1) -p2_x2(i-2) -p2_x2(i-3) p2_u2(i-1) p2_u2(i-2)];
end

% IV estimate of theta
% R_est1 = zeros(5, 5);
% f_est1 = zeros(5, 1);
% for i = 1:N2
%     R_est1 = R_est1 + 1/N2 * zeta2_xu(i,:)'*phi2(i,:);
%     f_est1 = f_est1 + 1/N2 * zeta2_xu(i,:)'*p2_y2(i);
% end
% theta_est_iv1 = R_est1 \ f_est1;

% Another equivalent representation, by R = 1/N * Zeta' * Phi, and f = 1/N * Zeta' * Y
theta_est_iv1 = (zeta2_xu'*phi2)\(zeta2_xu'*p2_y2);

mytext=sprintf(['The least-squares estimates obtained here is biased. According to the last part of Lecture 9, LS\n',...
                'estimate is only unbiased for equation error models with white noise (i.e. y(k)=B(z)/A(z)u(k)+1/A(z)e(k)).\n',...
                'The model here is an output error model so the LS estimate is biased.\n',...
                'In fact, for model of form\n',...
                'y(k) = phi(k)''*theta0 + v(k)\n',...
                'The asymptotic bias of LS estimate would be lim(K->inf)[theta_LS-theta0] = Rstar^-1 * fstar,\n',...
                'where Rstar=E{phi(k)phi''(k)}, and fstar=E{phi(k)v(k)}. Thus the condition for a LS estimate\n',...
                'to be unbiased is that Rstar is non-singular and phi(k) and v(k) is uncorrelated.\n',...
                'The given system could be written as y(k) = (1-A(z))y(k) + B(z)u(k) + A(z)e(k). Based on the\n',...
                'form of A(z) and B(z), phi(k) would contain past output and v(k) would contain past noise. These\n',...
                'components are correlated. Thus the bias of LS estimate would asymptotically converge to non-zero value.\n\n',...
                'The instrumental variables estimate obtained here is asymptotically unbiased, because the instrumental\n',...
                'variables chosen is purely generated by input data and is independent of the zero-mean noise v(k).\n',...
                'Thus fstar=E{zeta_ls(k)v(k)}=0, where zeta_ls(k) is the IV.\n',...
                'Then the estimate would be asymptotically unbiased as long as Rstar is invertible, which depend on\n',...
                'the input data. For the given experiment data, the Rstar matrix formed satisfies this requirement.\n',...
                'Therefore this estimate is asymptotically unbiased.\n']);
disp(mytext)


%% Part 2
mytext=sprintf('\n\n\nPart 2\n');
disp(mytext)

% delayed input iv of data 1
zeta1_di = zeros(N1, 5);
zeta1_di(1,:) = [0 0 0 0 0];
zeta1_di(2,:) = [p2_u1(1) 0 0 0 0];
zeta1_di(3,:) = [p2_u1(2) p2_u1(1) 0 0 0];
zeta1_di(4,:) = [p2_u1(3) p2_u1(2) p2_u1(1) 0 0];
zeta1_di(5,:) = [p2_u1(4) p2_u1(3) p2_u1(2) p2_u1(1) 0];
for i = 6:N1
    zeta1_di(i,:) = [p2_u1(i-1) p2_u1(i-2) p2_u1(i-3) p2_u1(i-4) p2_u1(i-5)];
end

% delayed input iv of data 1
zeta2_di = zeros(N2, 5);
zeta2_di(1,:) = [0 0 0 0 0];
zeta2_di(2,:) = [p2_u2(1) 0 0 0 0];
zeta2_di(3,:) = [p2_u2(2) p2_u2(1) 0 0 0];
zeta2_di(4,:) = [p2_u2(3) p2_u2(2) p2_u2(1) 0 0];
zeta2_di(5,:) = [p2_u2(4) p2_u2(3) p2_u2(2) p2_u2(1) 0];
for i = 6:N2
    zeta2_di(i,:) = [p2_u2(i-1) p2_u2(i-2) p2_u2(i-3) p2_u2(i-4) p2_u2(i-5)];
end

% IV estimate of theta
phi_all = [phi1; phi2];
zeta_all_di = [zeta1_di; zeta2_di];
y_all = [p2_y1; p2_y2];
theta_est_iv2 = (zeta_all_di'*phi_all) \ (zeta_all_di'*y_all);

mytext=sprintf(['The IV estimate obtained here is asymptotically unbiased, because zeta(k), the instrumental variables\n',                 ...
                'chosen here is only the input data and is independent of the zero-mean noise v(k). Thus\n',...
                'fstar=E{zeta_di(k)v(k)}=0, where zeta_di(k) is the delayed input IV.\n',...
                'Then the estimate would be asymptotically unbiased as long as Rstar is invertible, which depend on\n',...
                'the input data. For the given experiment data, the Rstar matrix formed satisfies this requirement.\n',...
                'Therefore this estimate is asymptotically unbiased.\n']);
disp(mytext)

% Debug code
%% Varify if the estimates are the same if filter 1/A_ls is applied to delayed input IV OR using only data 2
% G_filter = tf([1 0 0 0], A_ls, -1, 'Variable', 'z^-1');
% p2_u2_filtered = lsim(G_filter, p2_u2);
% zeta2_di_filtered = zeros(N2, 5);
% zeta2_di_filtered(1,:) = [0 0 0 0 0];
% zeta2_di_filtered(2,:) = [p2_u2_filtered(1) 0 0 0 0];
% zeta2_di_filtered(3,:) = [p2_u2_filtered(2) p2_u2_filtered(1) 0 0 0];
% zeta2_di_filtered(4,:) = [p2_u2_filtered(3) p2_u2_filtered(2) p2_u2_filtered(1) 0 0];
% zeta2_di_filtered(5,:) = [p2_u2_filtered(4) p2_u2_filtered(3) p2_u2_filtered(2) p2_u2_filtered(1) 0];
% for i = 6:N2
%     zeta2_di_filtered(i,:) = [p2_u2_filtered(i-1) p2_u2_filtered(i-2) p2_u2_filtered(i-3) p2_u2_filtered(i-4) p2_u2_filtered(i-5)];
% end

% p2_u1_filtered = lsim(G_filter, p2_u1);
% zeta1_di_filtered = zeros(N1, 5);
% zeta1_di_filtered(1,:) = [0 0 0 0 0];
% zeta1_di_filtered(2,:) = [p2_u1_filtered(1) 0 0 0 0];
% zeta1_di_filtered(3,:) = [p2_u1_filtered(2) p2_u1_filtered(1) 0 0 0];
% zeta1_di_filtered(4,:) = [p2_u1_filtered(3) p2_u1_filtered(2) p2_u1_filtered(1) 0 0];
% zeta1_di_filtered(5,:) = [p2_u1_filtered(4) p2_u1_filtered(3) p2_u1_filtered(2) p2_u1_filtered(1) 0];
% for i = 6:N1
%     zeta1_di_filtered(i,:) = [p2_u1_filtered(i-1) p2_u1_filtered(i-2) p2_u1_filtered(i-3) p2_u1_filtered(i-4) p2_u1_filtered(i-5)];
% end

% % Do not apply filter / Only use data 2
% theta_est_iv2_data2 = (zeta2_di'*phi2) \ (zeta2_di'*p2_y2);
% disp('Do not apply filter / Only use data 2')
% disp(theta_est_iv2_data2)

% % Apply filter / Only use data 2      ****** This one gives same result as theta_est_iv1 ******
% theta_est_iv2_filtered_data2 = (zeta2_di_filtered'*phi2) \ (zeta2_di_filtered'*p2_y2);
% disp('Apply filter / Only use data 2')
% disp(theta_est_iv2_filtered_data2)

% % Apply filter / Use both data 1 and data 2
% zeta_all_di_filtered = [zeta1_di_filtered; zeta2_di_filtered];
% theta_est_iv2_filtered_dataall = (zeta_all_di_filtered'*phi_all) \ (zeta_all_di_filtered'*y_all);
% disp('Apply filter / Use both data 1 and data 2')
% disp(theta_est_iv2_filtered_dataall)


% Debug code
%% See prediction
% G_iv1 = tf([0 theta_est_iv1(4) theta_est_iv1(5) 0], [1 theta_est_iv1(1) theta_est_iv1(2) theta_est_iv1(3)], -1, 'Variable', 'z^-1');
% G_iv2 = tf([0 theta_est_iv2(4) theta_est_iv2(5) 0], [1 theta_est_iv2(1) theta_est_iv2(2) theta_est_iv2(3)], -1, 'Variable', 'z^-1');

% y1_prdt1 = lsim(G_iv1, p2_u1);
% y1_prdt2 = lsim(G_iv2, p2_u1);

% figure(1)
% plot(p2_y1, 'color', 'k');
% hold on
% plot(y1_prdt1)
% hold on
% plot(y1_prdt2)

% y2_prdt1 = lsim(G_iv1, p2_u2);
% y2_prdt2 = lsim(G_iv2, p2_u2);

% figure(2)
% plot(p2_y2, 'color', 'k');
% hold on
% plot(y2_prdt1)
% hold on
% plot(y2_prdt2)

%% Part 3
mytext=sprintf('\n\n\nPart 3\n');
disp(mytext)

G_iv1 = tf([0 theta_est_iv1(4) theta_est_iv1(5) 0], [1 theta_est_iv1(1) theta_est_iv1(2) theta_est_iv1(3)], -1, 'Variable', 'z^-1');
G_iv2 = tf([0 theta_est_iv2(4) theta_est_iv2(5) 0], [1 theta_est_iv2(1) theta_est_iv2(2) theta_est_iv2(3)], -1, 'Variable', 'z^-1');

y_cv_pred1 = lsim(G_iv1, p2_u_cv);
y_cv_pred2 = lsim(G_iv2, p2_u_cv);

pred1_error = p2_y_cv - y_cv_pred1;
pred2_error = p2_y_cv - y_cv_pred2;

pred1_mse = mean(pred1_error.*pred1_error);
pred2_mse = mean(pred2_error.*pred2_error);

mytext=sprintf(['There are two reasons why the two estimates are different.\n',...
                '1.\n',...
                'According to Problem 1 in Exercise 9, for the given model, the instrumental variables estimate\n',...
                'based on least-squares instruments and that based on delayed inputs should be equivalent if\n',...
                'the instruments are generated in the following way:\n',...
                'zeta_ls = [-x(k-1) -x(k-2) -x(k-3) u(k-1) u(k-2)], where x(k) = B_LS(z)/A_LS(z) * u(k)\n',...
                'zeta_delayed_input = 1/A_LS(z) * [u(k-1) u(k-2) ... u(k-5)]\n',...
                'Note that the instruments generated from delayed inputs need to be filtered by 1 over the denominator\n',...
                'of the system used to generate x(k). However, this filter is not applied in Part 2, and the raw\n',...
                'input data is used as the instruments directly.\n',...
                '2.\n',...
                'The data used in the two estimations are different. In Part 1 only p2_u2 and p2_y2 is used in\n',...
                'the IV estimate, while in Part 2 all the data are used.\n\n',...
                'To make the two estimates the same, the two problems need to be resolved. The filter 1/A_LS(z)\n',...
                'need to be applied to input data when forming IV from delayed inputs, and the data used in the\n',...
                'two estimates need to be the same. It can be varified that the results would be the same if\n',...
                'these two things are applied.\n',...
                'More generally, the requirements for the parameter estimates generated from least squares based\n',...
                'instruments to be equal to that generated from delayed inputs are:\n',...
                '   1. zeta_ls = [-x(k-1) ... -x(k-a) u(k-1) ... u(k-b)], where x(k) = B_LS(z)/A_LS(z) * u(k),\n',...
                '   and zeta_delayed_input = 1/A_LS(z) * [u(k-1) u(k-2) ... u(k-a-b)]\n',...
                '   2. A_LS(z) and B_LS(z) have no common factor, which is usually true as A_LS(z) and B_LS(z)\n',...
                '   are similar to A(z) and B(z).\n',...
                '   3. Same experiment data is used to form the two instrumental variables.\n',...
                ]);
disp(mytext)


%% Return values
p2_a_ex1 = [theta_est_iv1(1) theta_est_iv1(2) theta_est_iv1(3)]';
p2_b_ex1 = [theta_est_iv1(4) theta_est_iv1(5)]';

p2_a_ex2 = [theta_est_iv2(1) theta_est_iv2(2) theta_est_iv2(3)]';
p2_b_ex2 = [theta_est_iv2(4) theta_est_iv2(5)]';

p2_mse_ex1 = pred1_mse;
p2_mse_ex2 = pred2_mse;

end

