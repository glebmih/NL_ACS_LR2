%% Детальный фазовый портрет нелинейной системы
clear; clc; close all;

%% 1. Определение системы
system_eq = @(t, X) [
    X(2);                           
    5*X(2)^2 + X(1)*(X(1) - 1)  
];

%% 2. Поиск и анализ особых точек
% Точки покоя: x2 = 0 и x1^2 - x1 = 0 => x1=0, x1=1
pts = [0, 0; 1, 0]; 

fprintf('--- Анализ особых точек ---\n');

for i = 1:size(pts, 1)
    x1 = pts(i,1);
    x2 = pts(i,2);
    
    % Матрица Якоби J = [df1/dx1, df1/dx2; df2/dx1, df2/dx2]
    % df1/dx1 = 0, df1/dx2 = 1
    % df2/dx1 = 2*x1 - 1, df2/dx2 = 10*x2
    J = [0, 1; 
         (2*x1 - 1), 10*x2];
    
    % Собственные числа
    eigs = eig(J);
    
    % Определение типа
    re = real(eigs);
    im = imag(eigs);
    
    if all(re < 0)
        type = 'Устойчивый узел/фокус';
    elseif all(re > 0)
        type = 'Неустойчивый узел/фокус';
    elseif any(re > 0) && any(re < 0)
        type = 'Седло';
    elseif all(re == 0) && any(im ~= 0)
        type = 'Центр (в линейном приближении)';
    else
        type = 'Вырожденная точка';
    end
    
    % Вывод в консоль
    fprintf('Точка %d: (%.1f, %.1f)\n', i, x1, x2);
    fprintf('  Собственные числа: %.2f + %.2fi, %.2f + %.2fi\n', ...
        re(1), im(1), re(2), im(2));
    fprintf('  Тип: %s\n\n', type);
end

%% 3. Настройка области
x1_range = linspace(-1, 2, 30); 
x2_range = linspace(-1, 1, 30);
[X1, X2] = meshgrid(x1_range, x2_range);

%% 4. Визуализация
figure('Color', 'w', 'Position', [100, 100, 900, 700]);
hold on; grid on;

% Поток (Streamlines) — это лучший способ увидеть нелинейность при большом кол-ве линий
% Вычисляем компоненты скорости для всего поля
U = X2;
V = 5*X2.^2 + X1.*(X1 - 1);

% Рисуем линии потока (streamline) — они плотнее и нагляднее обычных ode45
h = streamslice(X1, X2, U, V, 4); % 2 — плотность линий
set(h, 'Color', [0.2 0.4 0.6], 'LineWidth', 1);

%% 5. Добавляем выборочные траектории через ode45 для точности
% Создаем сетку стартовых точек
[startX, startY] = meshgrid(linspace(-0.5, 1.5, 6), linspace(-0.5, 0.5, 6));
start_points = [startX(:), startY(:)];

for i = 1:size(start_points, 1)
    % Используем короткое время, так как система быстро уходит в бесконечность
    options = odeset('RelTol', 1e-5, 'AbsTol', 1e-8);
    [~, sol] = ode45(system_eq, [0 0.5], start_points(i, :), options);
    
    % Рисуем только те части, которые не вышли за границы видимости
    idx = abs(sol(:,1)) < 3 & abs(sol(:,2)) < 2;
    plot(sol(idx,1), sol(idx,2), 'Color', [0.8 0.2 0.2 0.3], 'LineWidth', 0.5);
end

%% 5. Добавление особых точек на график
% Точка (0,0)
plot(0, 0, 'ko', 'MarkerFaceColor', 'g', 'MarkerSize', 10); 
text(-0.2, -0.15, 'Центр / Фокус (0,0)', 'FontSize', 10, 'FontWeight', 'bold');

% Точка (1,0)
plot(1, 0, 'ko', 'MarkerFaceColor', 'r', 'MarkerSize', 10);
text(1.1, -0.15, 'Седло (1,0)', 'FontSize', 10, 'FontWeight', 'bold');

% Оформление
xlabel('x_1');
ylabel('x_2');
title('Детальный фазовый портрет: \dot{x}_1=x_2, \dot{x}_2=5x_2^2 + x_1(x_1-1)');
axis([-1 2 -1 1]);
colormap jet;
hold off;

%% Локальные фазовые портреты с высокой плотностью и стрелками

% Координаты особых точек
pts = [0, 0; 1, 0]; 
titles = {'Локальный портрет: Центр (0,0)', 'Локальный портрет: Седло (1,0)'};
colors = [0 0.5 0; 0.8 0 0]; % Зеленый и Красный

figure('Color', 'w', 'Position', [100, 100, 1100, 500]);

for i = 1:size(pts, 1)
    subplot(1, 2, i);
    hold on; grid on;
    
    x_c = pts(i,1);
    y_c = pts(i,2);
    
    % Масштаб окрестности (чем меньше delta, тем "линейнее" выглядит портрет)
    delta = 0.25; 
    
    % Создаем мелкую сетку для расчета векторов
    res = 50; % Разрешение сетки
    x_val = linspace(x_c - delta, x_c + delta, res);
    y_val = linspace(y_c - delta, y_c + delta, res);
    [X1, X2] = meshgrid(x_val, y_val);
    
    % Расчет скоростей
    U = X2;
    V = 5*X2.^2 + X1.*(X1 - 1);
    
    % Построение линий тока со стрелками (streamslice)
    % Плотность линий регулируется параметром 3 (можно увеличить до 4-5)
    h = streamslice(X1, X2, U, V, 3); 
    
    % Настройка внешнего вида линий
    set(h, 'Color', [0.1 0.3 0.6], 'LineWidth', 1.1);
    
    % Рисуем саму особую точку
    plot(x_c, y_c, 'ko', 'MarkerFaceColor', colors(i,:), 'MarkerSize', 10, 'LineWidth', 1.5);
    
    % Оформление
    title(titles{i}, 'FontSize', 12);
    xlabel('x_1'); ylabel('x_2');
    axis([x_c-delta x_c+delta y_c-delta y_c+delta]);
    axis square;
    
    % Добавляем текстовую метку типа (опционально)
    if i == 1
        text(x_c - delta*0.9, y_c + delta*0.8, 'Устойчивое вращение', 'Color', [0 0.4 0]);
    else
        text(x_c - delta*0.9, y_c + delta*0.8, 'Гиперболическое рассеяние', 'Color', [0.6 0 0]);
    end
end

sgtitle('Детальный анализ окрестностей особых точек', 'FontSize', 14, 'FontWeight', 'bold');