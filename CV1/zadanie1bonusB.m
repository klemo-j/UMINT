clc; 
clear;
close all;


my_2D_func = @(x,y) -x .* sin(sqrt(abs(x))) - y .* sin(sqrt(abs(y)));


[X, Y] = meshgrid(-1000:10:1000, -1000:10:1000);
Z = my_2D_func(X, Y);


figure;
surf(X, Y, Z, 'FaceAlpha', 0.6, 'EdgeColor', 'none'); 
hold on;
colormap jet;
colorbar;
xlabel('x'); ylabel('y'); zlabel('z (hodnota funkcie)');
title('2D Deterministický horolezecký algoritmus');
view(45, 30); 

% Inicializácia parametrov
d = 0.5; 
x0 = -1000 + 2000 * rand(); 
y0 = -1000 + 2000 * rand();
z0 = my_2D_func(x0, y0);


plot3(x0, y0, z0, 'o', 'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'k', 'MarkerSize', 10);

% Hlavný cyklus algoritmu
max_steps = 1000; % Poistka proti nekonečnému cyklu
for step = 1:max_steps
    
    % Definovanie 8 susedných bodov v 2D priestore vo vzdialenosti 'd'
    neighbors = [
        x0+d, y0;   % vpravo
        x0-d, y0;   % vľavo
        x0, y0+d;   % hore
        x0, y0-d;   % dole
        x0+d, y0+d; % vpravo hore
        x0-d, y0-d; % vľavo dole
        x0+d, y0-d; % vpravo dole
        x0-d, y0+d  % vľavo hore
    ];
    
    best_z = z0;
    best_x = x0;
    best_y = y0;
    
    % Vyhodnotenie všetkých susedov
    for i = 1:size(neighbors, 1)
        nx = neighbors(i, 1);
        ny = neighbors(i, 2);
        
        % Kontrola, či nejdeme mimo definičný obor <-1000, 1000>
        if nx >= -1000 && nx <= 1000 && ny >= -1000 && ny <= 1000
            nz = my_2D_func(nx, ny);
            
            % Hľadáme minimum
            if nz < best_z
                best_z = nz;
                best_x = nx;
                best_y = ny;
            end
        end
    end
    
    
    if best_z < z0
        x0 = best_x;
        y0 = best_y;
        z0 = best_z;
        
        % Vykreslenie aktuálneho kroku
        plot3(x0, y0, z0, '.', 'Color', 'r', 'MarkerSize', 10);
       
    else
        
        break; 
    end
end


plot3(x0, y0, z0, 'o', 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'k', 'MarkerSize', 10);
hold off;

fprintf('Koniec algoritmu po %d krokoch.\nNájdené minimum z: %.4f v bode x: %.4f, y: %.4f\n', step, z0, x0, y0);