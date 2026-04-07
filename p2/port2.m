%% Фазовый портрет нелинейной системы (System 2)
clear; clc; close all;

% 1. Определение системы уравнений
% f1 = x2
% f2 = sin(x1)*x2 + ln(1 + x1^2)
system_eq = @(t, X) [
    X(2);                           
    sin(X(1))*X(2) + log(1 + X(1)^2)
];

% 2. Анализ особой точки (0,0)
% Матрица Якоби в (0,0):
% df1/dx1 = 0, df1/dx2 = 1
% df2/dx1 = cos(x1)*x2 + (2*x1)/(1+x1^2) -> в (0,0) это 0
% df2/dx2 = sin(x1) -> в (0,0) это 0
% J = [0 1; 0 0] - Точка вырожденная (линейная часть не дает полной картины)
fprintf('--- Анализ системы ---\n');
fprintf('Особая точка: (0,0)\n');
fprintf('Тип: Вырожденная (требуется численный анализ)\n\n');

% 3. Настройка графики
figure('Color', 'w', 'Position', [100, 100, 900, 700]);
hold on; grid on;

x1_lim = [-5, 5]; 
x2_lim = [-5, 5];
[X1, X2] = meshgrid(linspace(x1_lim(1), x1_lim(2), 30), ...
                    linspace(x2_lim(1), x2_lim(2), 30));

% Векторное поле
U = X2;
V = sin(X1).*X2 + log(1 + X1.^2);
L = sqrt(U.^2 + V.^2);
quiver(X1, X2, U./L, V./L, 0.5, 'Color', [0.8 0.8 0.8], 'AutoScale', 'off');

% 4. Построение линий тока (для густоты портрета)
h = streamslice(X1, X2, U, V, 2);
set(h, 'Color', [0.2 0.5 0.8], 'LineWidth', 1);

% 5. Отрисовка нескольких точных траекторий через ode45
start_points = [
    [-4, 4]; [-4, -4]; [4, 4]; [4, -4]; 
    [0.1, 0.1]; [-2, 0]; [2, 0]; [0, 3]
];

colors = lines(size(start_points, 1));
for i = 1:size(start_points, 1)
    [~, sol_f] = ode45(system_eq, [0 10], start_points(i, :));
    [~, sol_b] = ode45(system_eq, [0 -10], start_points(i, :));
    full_sol = [flipud(sol_b); sol_f];
    
    % Ограничиваем отрисовку пределами осей
    mask = full_sol(:,1) >= x1_lim(1) & full_sol(:,1) <= x1_lim(2) & ...
           full_sol(:,2) >= x2_lim(1) & full_sol(:,2) <= x2_lim(2);
    
    plot(full_sol(mask,1), full_sol(mask,2), 'Color', colors(i,:), 'LineWidth', 1.5);
end

% 6. Отметка особой точки
plot(0, 0, 'ro', 'MarkerFaceColor', 'r', 'MarkerSize', 10);

% Оформление
xlabel('x_1'); ylabel('x_2');
title('Фазовый портрет: \dot{x}_1 = x_2, \dot{x}_2 = sin(x_1)x_2 + ln(1 + x_1^2)');
axis([x1_lim x2_lim]);
hold off;