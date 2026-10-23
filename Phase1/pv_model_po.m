% ---- Datasheet parameters at STC (G=1000 W/m^2, T=25 C) ----

Pmax = 200.143;
Vmp = 26.3;
Imp = 7.61;
Voc = 32.9;
Isc = 8.21;
Kv = -0.123;
Ki = 0.0032;
Ns = 54;

% ---- Physical constants ----
q  = 1.602176634e-19;  % electron charge, Coulombs
k  = 1.380649e-23;     % Boltzmann constant, J/K
n  = 1.3;              % diode ideality factor (assumed)
Tstc = 25 + 273.15;   % STC temperature in Kelvin
Gstc = 1000;
Eg = 1.12;

% ---- Thermal Voltage ----
Vt = Ns*k*Tstc/q;

printf("Thermal Voltage = %.4f \n", Vt);


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
x0 = [Isc; 1e-9; 0.5; 1000];

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

function F = func2(I, V, Iph, I0, Rs, Rsh, n, Vt)
  F = I - Iph + ((V+I*Rs)/Rsh) + I0*(exp((V + I*Rs)/(n*Vt)) - 1);
end

V_vector = zeros(1,200);
V_vector(1) = 0.5*Voc;
direction = 1;
I_vector = zeros(1,200);
P_vector = zeros(1,200);
step = 0.1;

I_eq = @(I) func2(I, V_vector(1), Iph, I0, Rs, Rsh, n, Vt);
I_vector(1) = fzero(I_eq, Isc);
P_vector(1) = V_vector(1) .* I_vector(1);



for k = 2:200
  if k==2
    direction = direction;
  else
    if P_vector(k-1)>=P_vector(k-2)
      direction = direction;
    else
      direction = (-1)*direction;
    end
  end
  V_vector(k) = V_vector(k-1) + direction*step;
  I_eq = @(I) func2(I, V_vector(k), Iph, I0, Rs, Rsh, n, Vt);
  I_vector(k) = fzero(I_eq, Isc);
  P_vector(k) = V_vector(k) .* I_vector(k);
end

for m = 190:200
  printf("Powers = %.4f\n", P_vector(m));
end

figure;
plot(1:200, P_vector(1:200));
xlabel('Iteration (k)');
ylabel('Power (W)');
title('P&O: Power vs Iteration');
grid on;


