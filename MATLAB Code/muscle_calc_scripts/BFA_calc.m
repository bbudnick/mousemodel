%% Muscle Parameters to change for each muscle

%Default Maximum Muscle Force in Newtons

F_max = 0.876   % BFA
% fprintf('F_max: %f Newtons\n' , F_max); 

% % BFA
max_length = 0.01728694827
min_length = 0.0136425014

%% Muscle Parameters built on huristics that could see some change

%Huristic gotten from estimating strength of Ekeberg\Pearson
%cat muscles at their weakest
percent_at_edge = .7;

%Huristic from Thelen 2003
max_musc_deflection = .6; %fraction of total (percent/100)

%v_max derived from 'visual' averages of Johnson 2011 model for rat, range
%from 0.275 - 0.65
v_max = .4; %m/s

%KSE_deflect values are based on Ekeberg 2006 range from 80 to 200, is
%effectively the spring stiffness of the tendon
kse_deflect = 100; %F_max/L_max

%Amount of muscle length that is in the parallel element
kpe_percent = [.9 .9]; %The default amount

%% Parameters for setting the activation curve.
%The following parameters are based on having 0 output
%at -100mV, 99% output at -10 mV and the center at -50mV
curve_center = -.05;
curve_min = 0;
curve_min_pos = -.1;
curve_high = .99;
curve_high_pos = -.01;

%Initial guess for root finder for the steepness of the curve
x0 = 150;
%simplifications for root finder
z = curve_high - curve_min;
x = curve_center - curve_high_pos;
y = curve_center - curve_min_pos;

fun = @(s)z+1/(1+exp(s*y))-1/(1+exp(s*x));
s = fzero(fun,x0);

xoff = curve_center; %V
fprintf('xoff: \n %f mV \n' , xoff);
steepness = s;
yoff = curve_min-F_max/(1+exp(s*y)); %N
fprintf('yoff: \n %f N \n' , yoff);



%% Start computing other muscle parameters

%%%L_width; set such that at the range of muscle length, the minimum forces
%%%is at percent_at_edge less than maximum force
musc_range = max_length-min_length; %meters
l_width = abs(musc_range)/sqrt(1-percent_at_edge);
conv_l_width = l_width*1000; %convert to mm
fprintf('l_width: \n %f mm \n' , conv_l_width);

%%%Resting Length; set at the maximum length so that muscles get stronger
%%%as they get longer in the operating range of the animat
rest_length = max_length; %meters
conv_rest_length = rest_length*1000; 
fprintf('rest_length: \n %f mm \n' , conv_rest_length);

%%%Damping; set such that at maximum speed, all force is disipated in the
%%%damper
B = F_max/v_max; %Newtons/s
fprintf('B: \n %f Ns/m \n' , B);

%%%Kse value; set such that under maximum muscle force, the muscle deflects
%%%by the amount set in kse_deflect
kse = kse_deflect*F_max/rest_length;
fprintf('kse: \n %f N/m \n' , kse);

%%%Kpe value; calculated such that under maximum load, the total muscle
%%%deflects by the stated amount in max_deflect
kpe = kse*F_max/(max_length*max_musc_deflection*kse - F_max); %N/m
fprintf('kpe: \n %f N/m \n' , kpe);

M = zeros();
filler = 1234; 

%M = [max_length, min_length, xoff, steepness, yoff, l_width, rest_length, B, kse, kpe];




% formatted to be consistent with LNB_2 Excel sheet
M = [B, kpe, kse, filler, filler, conv_l_width, conv_rest_length, filler, filler, steepness, xoff, yoff];
% fprintf('%f\n' , M); % SOL
T = array2table(M); 
writetable(T, 'BFA_dat.xlsx');

