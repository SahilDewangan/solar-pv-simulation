clear; clc;

% Run: Kp = 0.0005, Ki = 0.1, Kd = 0, t_end = 0.6 s

% Parameters
Vin = 263;
R   = 80;
L   = 1.18e-3;
C   = 8.56e-6;
V_ref = 400;

% Time Setup
dt     = 1e-6;
t_end  = 0.6;
N = round(t_end/dt);

% For storing values
Vout = zeros(1,N);
I_L = zeros(1,N);
Vout(1) = Vin;
D = zeros(1,N);
D(1) = 0;
time = linspace(0, t_end, N);

e_int = 0;
e_prev = 0;

Kp = 0.0005;
Ki = 0.1;
Kd = 0;

% Boost Converter Loop

for k = 1:(N-1)

    e = V_ref - Vout(k);
    e_int = e_int + e*dt;
    e_der = (e - e_prev)/dt;

    Dset = Kp*e + Ki*e_int + Kd*e_der;
    D(k) = max(0, min(Dset, 0.9));

  di_dt = (Vin - (1 - D(k))*Vout(k))/L;
  dv_dt = ((1 - D(k))*I_L(k) - (Vout(k)/R))/C;

 Vout(k+1) = Vout(k) + dt*dv_dt;
 I_L(k+1) = I_L(k) + dt*di_dt;
 if I_L(k+1) < 0
   I_L(k+1) = 0;
 end

 e_prev = e;
end

 D(N) = D(N-1);

 printf("Vout = %.2f V, D = %.4f, iL = %.2f A\n", Vout(end), D(end), I_L(end));

% Checking if the ripple slowly decays
w1 = (time > 0.15) & (time < 0.20);
w2 = (time > 0.55) & (time < 0.60);
printf("Vout ripple: %.5f V (early), %.5f V (late)\n", max(Vout(w1)) - min(Vout(w1)), max(Vout(w2)) - min(Vout(w2)));


% Plots
figure;
subplot(1,3,1);
plot(time, Vout, 'r');
xlabel('Time (s)'); ylabel('V_{out} (V)'); grid on;
title("Voltage Plot");

subplot (1,3,2);
plot(time, I_L, 'g');
xlabel('Time (s)'); ylabel('Inductor Current (A)'); grid on;
title("Inductor Current Plot");

subplot(1,3,3);
plot(time, D, 'b');
xlabel('Time (s)'); ylabel('Duty Cycle'); grid on;
title("Duty Cycle Plot");
