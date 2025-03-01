function [RES_b, RES_se] = rolling(y, X, m)
    % y = variabile dipendente   
    % X = regressori (per i grafici: MKT deve essere il primo) 
    % m = lunghezza della finestra mobile

    % Preallocazione delle matrici per gli stimati e gli errori standard
    num_coeff = size(X, 2) + 1;  % Numero di regressori + 1 per l'intercetta
    RES_b = zeros(length(y) - m + 1, num_coeff); % stime beta
    RES_se = zeros(length(y) - m + 1, num_coeff); % HAC SE(beta)

    % Iterazione sulla finestra mobile
    for iter = 1:length(y) - m + 1
        yy = y(iter:iter + m - 1, :);
        XX = X(iter:iter + m - 1, :);

        [~, se, coeff] = hac(XX, yy);

        % Assegna gli stimati e gli errori standard alla matrice di output
        RES_b(iter, :) = coeff';
        RES_se(iter, :) = se';
    end
end

function plot_rolling(y, X, m)
    % Calcola gli stimati e gli errori standard con la finestra mobile
    [RES_b, RES_se] = rolling(y, X, m);

    % Determina la lunghezza del dataset
    n = size(RES_b, 1);  % Lunghezza del dataset dopo la finestra mobile

    % Lettura file 01_portofolios
    dataTable = readtable('C:\Users\tommi\OneDrive\Desktop\File tesi\Rolling regression\01_portfolios.xlsx');
    % Estrazione prima data (dalla prima cella)
    firstDate = dataTable{1, 1};
    % Conversione della data in un formato datetime
    start_date = datetime(firstDate, 'InputFormat', 'dd/MM/yyyy') + calmonths(m-1);
    % Data di inizio rolling window
    time_vector = start_date + calmonths(0:n-1);  % Vettore di mesi a partire dalla data di inizio

    % Plot per alpha
    alpha = RES_b(:, 1);  % Valori di alpha
    se_alpha = RES_se(:, 1);  % Errori standard di alpha

    % Calcolo degli intervalli di confidenza per alpha
    nu = m - (size(X, 2) + 1);
    Studt = tinv(0.025, nu);  
    SE_alpha = se_alpha * Studt;
    SE_low_alpha = alpha + SE_alpha;
    SE_up_alpha = alpha - SE_alpha;

    % Plot di alpha
    figure;
    plot(time_vector, alpha, 'DisplayName', 'alpha');
    hold on;

    % Plot degli intervalli di confidenza per alpha
    plot(time_vector, SE_low_alpha, ':b');
    plot(time_vector, SE_up_alpha, ':b');

    % Aggiunta di una linea orizzontale a y=0 per alpha
    yline(0, '--', 'DisplayName', 'y=0');

    % Aggiunta della legenda per alpha
    %legend('show');

    % Attivazione della griglia per alpha
    grid on;

    % Aggiunta etichetta ylabel per alpha
    ylabel('Alpha');

    
    % Calcolo dell'intervallo delle etichette
    num_dates = length(time_vector);
    if num_dates <= 49
        interval = 6;
    elseif num_dates <= 72
        interval = 12;
    elseif num_dates <= 120
        interval = 24;
    else
        interval = 36; % Aggiungi ulteriori condizioni se necessario
    end


    % Impostazione del formato della data sull'asse x
    ax = gca;
    ax.XTick = time_vector(1:interval:end);
    xtickformat('MMM yyyy');

    % Imposta le dimensioni del plot
    pbaspect([1 1 1]);

    % Aggiunta del titolo al plot di alpha
    title('Title for Alpha');

        % Aggiunta del riquadro con il testo "m=24"
    annotation('textbox', [0.7, 0.8, 0.1, 0.1], ...
               'String', sprintf('m=%d', m), ...
               'FitBoxToText', 'on', ...
               'BackgroundColor', 'white', ...
               'EdgeColor', 'black');

    % Terminare il hold per alpha
    hold off;

    % Plot per beta
    figure;
    beta = RES_b(:, 2);  % Valori di beta
    se_beta = RES_se(:, 2);  % Errori standard di beta

    % Calcolo degli intervalli di confidenza per beta
    SE_beta = se_beta * Studt;
    SE_low_beta = beta - SE_beta;
    SE_up_beta = beta + SE_beta;

    % Plot di beta
    plot(time_vector, beta, 'DisplayName', 'beta');
    hold on;

    % Plot degli intervalli di confidenza per beta
    plot(time_vector, SE_low_beta, ':b');
    plot(time_vector, SE_up_beta, ':b' );

    % Aggiunta di una linea orizzontale a y=1 per beta
    yline(1, '--', 'DisplayName', 'y=1');

    % Aggiunta della legenda per beta
    %legend('show');

    % Attivazione della griglia per beta
    grid on;

    % Aggiunta etichetta ylabel per beta
    ylabel('Beta');

    % Impostazione del formato della data sull'asse x
    ax = gca;
    ax.XTick = time_vector(1:interval:end);
    xtickformat('MMM yyyy')

    % Imposta le dimensioni del plot
    pbaspect([1 1 1]);

    % Aggiunta del titolo al plot di beta
    title('Title for Beta');

    % Aggiunta del riquadro con il testo "m=24"
    annotation('textbox', [0.7, 0.8, 0.1, 0.1], ...
               'String', sprintf('m=%d', m), ...
               'FitBoxToText', 'on', ...
               'BackgroundColor', 'white', ...
               'EdgeColor', 'black');

    % Terminare il hold per beta
    hold off;
end

% Funzione plot_rolling
% y = variabile dipendente
% X = regressori
% m = lunghezza della finestra mobile
% plot_rolling(y, X, m);


plot_rolling(y, X, m)