
function plot_parameter(good_data, seizure_data, parameter, fs, N_FFT, overlapping, window_size, default_window)
    T_list_good = {};
    F_list_good = {};
    Spec_list_good = {};

    T_list_seizure = {};
    F_list_seizure = {};
    Spec_list_seizure = {};

    if parameter == "N_FFT"
        len = length(N_FFT);
        ovr_lap = overlapping(1);
        w_s = window_size(1);
    elseif parameter == "w_S"
        len = length(window_size);
        n_f = N_FFT(1);
        ovr_lap = overlapping(1);
    elseif parameter == "ovr_lap"
        len = length(overlapping);
        n_f = N_FFT(1);
        w_s = window_size(1);

    elseif parameter == "window_type"
        n_f = N_FFT(1);
        w_s = window_size(1);
        ovr_lap = overlapping(1);
        types = {'Rectangular', 'Triangular', 'Hamming', 'Blackman'};
        len = length(types);
    end
    
    fig_G = figure;
    fig_S = figure;

    for i = 1:len
        if parameter == "N_FFT"
            [T_G, F_G, Spec_G] = get_spectrum(good_data, fs, N_FFT(i), ovr_lap, w_s, default_window);
            [T_S, F_S, Spec_S] = get_spectrum(seizure_data, fs, N_FFT(i), ovr_lap, w_s, default_window);            
        elseif parameter == "w_S"
            [T_G, F_G, Spec_G] = get_spectrum(good_data, fs, n_f, ovr_lap, window_size(i), default_window);
            [T_S, F_S, Spec_S] = get_spectrum(seizure_data, fs, n_f, ovr_lap, window_size(i), default_window);  
        elseif parameter == "ovr_lap"
            [T_G, F_G, Spec_G] = get_spectrum(good_data, fs, n_f, overlapping(i), w_s, default_window);
            [T_S, F_S, Spec_S] = get_spectrum(seizure_data, fs, n_f, overlapping(i), w_s, default_window);  
        elseif parameter == "window_type"
            [T_G, F_G, Spec_G] = get_spectrum(good_data, fs, n_f, ovr_lap, w_s, types{i});
            [T_S, F_S, Spec_S] = get_spectrum(seizure_data, fs, n_f, ovr_lap, w_s, types{i});  
        end

        T_list_good{i} = T_G;
        F_list_good{i} = F_G;
        Spec_list_good{i} = Spec_G;

        T_list_seizure{i} = T_S;
        F_list_seizure{i} = F_S;
        Spec_list_seizure{i} = Spec_S;
    end

    % plot the N_FFT Changes
    if parameter == "N_FFT"
       title_str = sprintf('overlapping: %.3f, window size: %.3f, window_type: %s (changing N-FFT)', ovr_lap, w_s, default_window);
    elseif parameter == "w_S"
       title_str = sprintf('overlapping: %.3f, N-FFT: %.3f, window_type: %s (changing w_S)', ovr_lap, n_f, default_window);
    elseif parameter == "ovr_lap"
        title_str = sprintf('N-FFT: %.3f, window size: %.3f, window_type: %s (changing ovr_lap)', n_f, w_s, default_window);
    elseif parameter == "window_type"
       title_str = sprintf('overlapping: %.3f, window size: %.3f, N-FFT: %.3f (changing window_type)', ovr_lap, w_s, n_f);
    end

    fig_G.Name = ['Good Data (' title_str ')'];
    fig_S.Name = ['Seizure Data (' title_str ')'];
    for i = 1:len
        if parameter == "N_FFT"
            t = [' Spectrogram N-FFT Value: ', num2str(N_FFT(i))];
        elseif parameter == "w_S"
            t = [' Spectrogram window size Value: ', num2str(window_size(i))];
        elseif parameter == "ovr_lap"
            t = [' Spectrogram overlapping Value: ', num2str(overlapping(i))];
        elseif parameter == "window_type"
            t = [' Spectrogram window-type Value: ', types{i}];
        end
        t_our = ['Our' t];
        t_built_in = ['Built in' t];

        % Our function
        figure(fig_G);
        subplot(len , 2, 2*(i-1) + 1)
        imagesc(T_list_good{i}, F_list_good{i}, 20 * log10(Spec_list_good{i}));
        axis xy;
        xlabel('Time (s)');
        ylabel('Frequency (Hz)');
        title(t_our);
        colorbar;
        colormap jet;

        figure(fig_S);
        subplot(len , 2, 2*(i-1) + 1)
        imagesc(T_list_seizure{i}, F_list_seizure{i}, 20 * log10(Spec_list_seizure{i}));
        axis xy;
        xlabel('Time (s)');
        ylabel('Frequency (Hz)');
        title(t_our);
        colorbar;
        colormap jet;
        
        % Built in function
        figs = {fig_G, fig_S};
        dat = {good_data, seizure_data};

        for j = 1:2
            figure(figs{j});
            subplot(len , 2, 2*(i-1)+2)
            if parameter == "N_FFT"
                window = generate_window(w_s, default_window);
                [ss, ff, tt] = spectrogram(dat{j}, window, floor(ovr_lap * length(window)), N_FFT(i), fs);
            elseif parameter == "w_S"
                window = generate_window(window_size(i), default_window);
                [ss, ff, tt] = spectrogram(dat{j}, window, floor(ovr_lap * length(window)), n_f, fs);
            elseif parameter == "ovr_lap"
                window = generate_window(w_s, default_window);
                [ss, ff, tt] = spectrogram(dat{j}, window, floor(overlapping(i) * length(window)), n_f, fs);
            elseif parameter == "window_type"
                window = generate_window(w_s, types{i});
                [ss, ff, tt] = spectrogram(dat{j}, window, floor(ovr_lap * length(window)), n_f, fs);
            end
            imagesc(tt, ff, 20 * log10(abs(ss)));
            axis xy;
            xlabel('Time (s)');
            ylabel('Frequency (Hz)');
            title(t_built_in);
            colorbar;
            colormap jet;
        end
    end
end

function window = generate_window(window_size, default_window)
    % Generate the window
    M = window_size; 
    i = 0:M-1; 
    % Initialize window
    window = zeros(1, M); 
    
    switch default_window
        case 'Rectangular'
            % Rectangular Window
            window = ones(1, M); % All values are 1
        case 'Triangular'
            % Triangular Window
            window = 1 - abs((i - (M-1)/2) / ((M-1)/2));
        case 'Hamming'
            % Hamming Window
            window = 0.54 - 0.46 * cos(2*pi*i/(M-1));
        case 'Blackman'
            % Blackman Window
            window = 0.42 - 0.5 * cos(2*pi*i/(M-1)) + 0.08 * cos(4*pi*i/(M-1));
    end
end
