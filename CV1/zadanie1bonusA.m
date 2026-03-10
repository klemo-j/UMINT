clc; clear; close all;



x = -1000:1:1000;   
Pop = x';          

Fit = testfn3c(Pop);  

plot(x, Fit, 'LineWidth', 2)
grid on
xlabel('x')
ylabel('F(x)')
hold on;

pocet_spusteni = 100;        
najdene_minima = zeros(1, pocet_spusteni);   
najdene_x = zeros(1, pocet_spusteni);        

for k = 1:pocet_spusteni

    x0 = randi([-999, 999]);  
    y = testfn3c([x0]);         
    d=10;                        
    max_iter = 1000;

    for i = 1:max_iter

        
      x_lavo_temp  = x0 - d;
        x_pravo_temp = x0 + d;
        
      
        x_lavo = max(-1000, x_lavo_temp);
       
        x_pravo = min(1000, x_pravo_temp);

        y_lavo  = testfn3c([x_lavo]);
        y_pravo = testfn3c([x_pravo]);

       
        if y_lavo < y
            x0 = x_lavo;
            y  = y_lavo;
            plot(x0, y, 'ro', 'MarkerFaceColor','r');  

        elseif y_pravo < y
            x0 = x_pravo;
            y  = y_pravo;
            plot(x0, y, 'ro', 'MarkerFaceColor','r'); 

        else
            break
        end

       

    end

    
    najdene_minima(k) = y;
    najdene_x(k) = x0;
    plot(x0, y, 'ro', 'MarkerFaceColor','r');  
end



[global_min, index] = min(najdene_minima);
global_x = najdene_x(index);


plot(global_x, global_min, 'go', 'MarkerSize',10, 'MarkerFaceColor','g');
hold off;