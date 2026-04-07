model_name = 'phase_port_simulink'; % имя файла .slx
% Массив начальных точек (например, x1 от -1 до 2)
start_x1 = [-0.2:0.002:0.2]; 
hold on;
grid on;

for i = 1:length(start_x1)
    % Создаем объект настройки симуляции
    in = Simulink.SimulationInput(model_name);
    
    % Передаем начальное значение прямо в блок Интегратора
    % 'Integrator1' — это точное имя блока в вашей модели
    in = in.setBlockParameter([model_name '/Integrator1'], 'InitialCondition', num2str(start_x1(i)));
    in = in.setBlockParameter([model_name '/Integrator2'], 'InitialCondition', '0'); % x2 всегда 0 в начале
    
    % Запуск
    out = sim(in);
    
    % Построение (убедитесь, что имена x1_data совпадают с именами в To Workspace)
    plot(out.x1_data, out.x2_data, 'LineWidth', 1.2);
end