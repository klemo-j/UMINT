clc; 
clear;

x_rand = linspace(-1000, 1000 , 1000);
y_funk = arrayfun(@testfn3c, x_rand);

figure;
plot(x_rand, y_funk, 'k', 'LineWidth', 1.5);
hold on;
xlabel('x');
ylabel('y');
title('Horolezecký algoritmus');

d = 0.1;
x0 = -1000 + (1000 - (-1000)) * rand(1,1);
y0 = testfn3c(x0);


plot(x0, y0, 'o', 'MarkerFaceColor', 'g', 'MarkerEdgeColor', 'g');

while true 
    
   
    left  = testfn3c(x0 - d);
    right = testfn3c(x0 + d);

  
    if left >= y0 && right >= y0
        break;
    end

  
    if right < left
        x0 = x0 + d;
        y0 = right;
    else
        x0 = x0 - d;
        y0 = left;
    end

    plot(x0, y0,'x', 'Color', 'r');
  

end


plot(x0, y0, 'o', 'MarkerFaceColor', 'b', 'MarkerEdgeColor', 'b');

hold off;
