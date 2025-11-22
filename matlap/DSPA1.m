function DSPA1(channels, N_FFT, overlapping, window_size, default_window)
    summary_file = 'chb12-summary.txt';
    fileNames = {'data\chb12_29_data.mat', ...
                 'data\chb12_29_header.mat', ...
                 'data\chb12_32_data.mat', ...
                 'data\chb12_32_header.mat'};    
    fs = 256;
    good_index = 3;
    bad_index = 1;

    [good_data, seizure_data] = Pre_Processer.get_good_and_bad_data(summary_file, fileNames, good_index, bad_index, channels, fs);

    % Plot the seizure_data (small test)
    time = (1:length(good_data)) / fs;
    figure;
    plot(time, seizure_data, 'r-', 'LineWidth', 1.5);
    hold on;
    plot(time, good_data, 'b-', 'LineWidth', 1.5);
    xlabel('Time (seconds)');
    ylabel('Data Value');
    title('Good Data and Seizure Data');
    legend('Seizure Data', 'Good Data');
    grid on;
    hold off;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% write your code here %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    plot_parameter(good_data, seizure_data, 'N_FFT', fs, N_FFT, overlapping, window_size, default_window);
    plot_parameter(good_data, seizure_data, 'w_S', fs, N_FFT, overlapping, window_size, default_window);
    plot_parameter(good_data, seizure_data, 'ovr_lap', fs, N_FFT, overlapping, window_size, default_window);
    plot_parameter(good_data, seizure_data, 'window_type', fs, N_FFT, overlapping, window_size, default_window);


    % % Frequency Response of the Window ----
    % % Frequency response (FFT of the window)
    % window_fft = fft(window, N_FFT);
    % window_magnitude = abs(window_fft(1:N_FFT/2 + 1)); % One-sided spectrum
    % freq_axis_window = (0:N_FFT/2) * (fs / N_FFT);
    % 
    % % Plot the frequency response
    % figure;
    % plot(freq_axis_window, 20 * log10(window_magnitude / max(window_magnitude)), 'LineWidth', 1.5);
    % xlabel('Frequency (Hz)');
    % ylabel('Magnitude (dB)');
    % title(['Frequency Response of ' default_window ' Window']);
    % grid on;
    % ylim([-100 0]); % Limit y-axis to observe side lobes more clearly
    % 
    % % Highlight main and side lobes
    % hold on;
    % [main_lobe_peak, main_lobe_idx] = max(window_magnitude);
    % plot(freq_axis_window(main_lobe_idx), 20 * log10(main_lobe_peak / max(window_magnitude)), 'ro', 'MarkerFaceColor', 'r');
    % text(freq_axis_window(main_lobe_idx), 20 * log10(main_lobe_peak / max(window_magnitude)) + 5, 'Main Lobe', 'Color', 'red');
    % hold off;

end