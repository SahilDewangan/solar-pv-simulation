% Datasheet parameters at STC (G=1000 W/m^2, T=25 C)

Pmax = 200.143;
Vmp = 26.3;
Imp = 7.61;
Voc = 32.9;
Isc = 8.21;
Kv = -0.123;
Ki = 0.0032;
Ns = 54;

% Physical constants
q  = 1.602176634e-19;  % electron charge, Coulombs
k  = 1.380649e-23;     % Boltzmann constant, J/K
n  = 1.3;              % diode ideality factor (assumed)
Tstc = 25 + 273.15;    % STC temperature in Kelvin
Gstc = 1000;           % Irradiance at STC in W/m^2
Eg = 1.12;             % Band gap energy

% Thermal Voltage
Vt = Ns*k*Tstc/q;

printf("Thermal Voltage = %.4f \n", Vt);

% Solving the 4 equations to get the photocurrent, reverse-saturation current, series and shunt resistance
function F = func1(x, Isc, Voc, Imp, Vmp, n, Vt)
  Iph = x(1);
  I0  = x(2);
  Rs  = x(3);
  Rsh = x(4);

  G1 = (I0/(n*Vt))*(exp((Vmp + Imp*Rs)/(n*Vt)));

  F(1) = Isc - Iph + (Isc*Rs)/(Rsh) + I0*(exp((Isc*Rs)/(n*Vt))-1);
  F(2) = Iph - (Voc/Rsh) - I0*(exp((Voc/(n*Vt)))-1);
  F(3) = Iph - Imp - ((Vmp + Imp*Rs)/Rsh) - I0*(exp((Vmp + Imp*Rs)/(n*Vt))-1);
  F(4) = -((G1 + 1/(Rsh))/(1 + Rs*(G1 + 1/(Rsh)))) + (Imp/Vmp);

end
x0 = [Isc; 1e-9; 0.5; 1000];        % initial guess

% Alloting the solutions from the solver to the respective terms
F_handle = @(x) func1(x, Isc, Voc, Imp, Vmp, n, Vt);
x_sol = fsolve(F_handle, x0);
Iph = x_sol(1);
I0  = x_sol(2);
Rs  = x_sol(3);
Rsh = x_sol(4);

printf("Iph = %.4f A \n", Iph);
printf("I0 = %.4e A \n", I0);
printf("Rs = %.4f ohms \n", Rs);
printf("Rsh = %.4f ohms \n", Rsh);

% Solving for finding V and I respectively
function F = func2(I, V, Iph, I0, Rs, Rsh, n, Vt)
  F = I - Iph + ((V+I*Rs)/Rsh) + I0*(exp((V + I*Rs)/(n*Vt)) - 1);
end

V_axis1 = linspace(0, Voc, 1000);
I_axis1 = zeros(size(V_axis1));
for i = 1:length(V_axis1)
  I_eq = @(I) func2(I, V_axis1(i), Iph, I0, Rs, Rsh, n, Vt);
  I_axis1(i) = fzero(I_eq, Isc);
end

P_axis1 = V_axis1.*I_axis1;

Iph_stc = Iph;
I0_stc = I0;

function [Iph_new, I0_new] = correct_param(G, T, Eg, Iph_stc, I0_stc, Ki, q, k, n, Ns, Gstc, Tstc)
  Iph_new = Iph_stc*(G/Gstc)+Ki*(T - Tstc);
  I0_new = I0_stc*((T/Tstc)^3)*(exp(((q*Eg)/(n*k))*((1/Tstc)-(1/T))));
end

% for different irradiance values
G_values = [1000, 800, 600, 400, 200];
T = Tstc;
I_curvesG = zeros(length(V_axis1), length(G_values));

for i = 1:length(G_values)
  [Iph_new, I0_new] = correct_param(G_values(i), T, Eg, Iph_stc, I0_stc, Ki, q, k, n, Ns, Gstc, Tstc);
  printf("Iph_new = %.4f\n", Iph_new);
  printf("I0_new = %.4e\n", I0_new);

  for m = 1:length(V_axis1)
    I_eq = @(I) func2(I, V_axis1(m), Iph_new, I0_new, Rs, Rsh, n, Vt);
    I_curvesG(m, i) = fzero(I_eq, Isc);
  end
end

% for different Temperature values
T_values = [25+273.15, 50+273.15, 75+273.15];
G = Gstc;
I_curvesT = zeros(length(V_axis1), length(T_values));

for i = 1:length(T_values)
  [Iph_new, I0_new] = correct_param(G, T_values(i), Eg, Iph_stc, I0_stc, Ki, q, k, n, Ns, Gstc, Tstc);

  for m = 1:length(V_axis1)
    I_eq = @(I) func2(I, V_axis1(m), Iph_new, I0_new, Rs, Rsh, n, Vt);
    I_curvesT(m, i) = fzero(I_eq, Isc);
  end
end

figure;
subplot(2,2,1);
hold on;
box on;
for i = 1:length(G_values)
  plot(V_axis1, I_curvesG(:,i));
end
hold off;
xlabel("Voltage(V)");
ylabel("Current(A)"); ylim([0, Isc*1.1]);
grid on;
legend('1000 W/m^2', '800 W/m^2', '600 W/m^2', '400 W/m^2', '200 W/m^2', 'Location', 'northeastoutside');
title('I-V Characteristics vs. Irradiance (T = 25 C)', 'FontWeight', 'bold');

subplot(2,2,3);
hold on;
box on;
for i = 1:length(G_values)
  P_curvesG(:,i) = V_axis1' .* I_curvesG(:,i);
  plot(V_axis1, P_curvesG(:,i));
end
xlabel("Voltage(V)");
ylabel("Power(W)"); ylim([0, Voc*Isc*1.1]);
grid on;
legend('1000 W/m^2', '800 W/m^2', '600 W/m^2', '400 W/m^2', '200 W/m^2', 'Location', 'northeastoutside');
title('P-V Characteristics vs. Irradiance (T = 25 C)', 'FontWeight', 'bold');


subplot(2,2,2);
hold on;
box on;
for i = 1:length(T_values)
  plot(V_axis1, I_curvesT(:,i));
end
xlabel("Voltage(V)");
ylabel("Current(A)"); ylim([0, Isc*1.1]);
grid on;
legend('25C', '50C', '75C',  'Location', 'northeastoutside');
title('I-V Characteristics vs. Temperature (G = 1000 W/m^2)', 'FontWeight', 'bold');

subplot(2,2,4);
hold on;
box on;
for i = 1:length(T_values)
  P_curvesT(:,i) = V_axis1' .* I_curvesT(:,i);
  plot(V_axis1, P_curvesT(:,i));
end
xlabel("Voltage(V)");
ylabel("Power(W)"); ylim([0, Voc*Isc*1.1]);
grid on;
legend('25C', '50C', '75C', 'Location', 'northeastoutside');
title('P-V Characteristics vs. Temperature (G = 1000 W/m^2)', 'FontWeight', 'bold');
