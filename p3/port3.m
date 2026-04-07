%% Фазовый портрет системы: x'' - (x')^4*x - x' = 0
clear; clc; close all;

% 1. Определение системы
% X(1) = x, X(2) = dx/dt
system_eq = @(t, X) [
    X(2);                           % dx1/dt = x2
    X(2)^4 * X(1) + X(2)            % dx2/dt = x2^4 * x1 + x2
];

% 2. Настройка графики
figure('Color', 'w', 'Position', [100, 100, 900, 700]);
hold on; grid on;

x1_lim = [-5, 5]; 
x2_lim = [-5, 5];
[X1, X2] = meshgrid(linspace(x1_lim(1), x1_lim(2), 30), ...
                    linspace(x2_lim(1), x2_lim(2), 30));

% Векторное поле
U = X2;
V = X2.^4 .* X1 + X2;
L = sqrt(U.^2 + V.^2);
quiver(X1, X2, U./L, V./L, 0.5, 'Color', [0.8 0.8 0.8], 'AutoScale', 'off');

% 3. Линии тока (для наглядности структуры)
h = streamslice(X1, X2, U, V, 2.5);
set(h, 'Color', [0.1 0.4 0.7], 'LineWidth', 1);

% 4. Точные траектории через ode45
% Берем точки вокруг начала координат и по краям
start_points = [
    [0.1, 0.1]; [-0.1, -0.1]; [2, 1]; [-2, -1]; 
    [4, 0.5]; [-4, -0.5]; [0.5, 4]; [-0.5, -4]
];

for i = 1:size(start_points, 1)
    [~, sol_f] = ode45(system_eq, [0 5], start_points(i, :));
    [~, sol_b] = ode45(system_eq, [0 -5], start_points(i, :));
    full_sol = [flipud(sol_b); sol_f];
    
    mask = full_sol(:,1) >= x1_lim(1) & full_sol(:,1) <= x1_lim(2) & ...
           full_sol(:,2) >= x2_lim(1) & full_sol(:,2) <= x2_lim(2);
    
    plot(full_sol(mask,1), full_sol(mask,2), 'LineWidth', 1.5);
end

% 5. Особая точка (0,0)
plot(0, 0, 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 10);

% 6. Анализ в консоли
% J = [0, 1; 0, 1] в точке (0,0)
% Собственные числа: 0 и 1.
fprintf('--- Анализ точки (0,0) ---\n');
fprintf('Собственные числа: 0 и 1\n');
fprintf('Тип: Вырожденный неустойчивый узел (критическая точка)\n');

xlabel('x (координата)');
ylabel('dx/dt (скорость)');
title('Фазовый портрет: \ddot{x} - (\dot{x})^4 x - \dot{x} = 0');
axis([x1_lim x2_lim]);
hold off;