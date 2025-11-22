function [T, F, Spec, wn] = get_spectrum(data, fs, N_FFT, overlapping, window_size, default_window)
    % Function to analyze a signal and visualize its spectrogram and window frequency response.
    % Inputs:
    %   - seizure_data: Signal to be analyzed
    %   - fs: Sampling frequency of the signal
    %   - N_FFT: Number of FFT points
    %   - overlapping: Overlap ratio (0 to 1)
    %   - window_size: Size of the window in samples
    %   - default_window: Type of window ('Rectangular', 'Triangular', 'Hamming', 'Blackman')

    % Validate Inputs


    % Generate the window
    test_data = data;
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
    wn = window;
    
    % Calculate the number of overlapping points
    N_overlap = floor(overlapping * window_size);
    step_size = window_size - N_overlap;
    num_segments = floor((length(test_data) - window_size) / step_size) + 1;

    % Initialize spectrogram matrix
    custom_spectrogram = zeros(N_FFT / 2 + 1, num_segments);

    for j = 1:num_segments
        start_idx = (j-1) * step_size + 1;
        end_idx = start_idx + window_size - 1;

        if end_idx > length(test_data)
            break;
        end

        segment = test_data(start_idx:end_idx) .* window'; % Apply window
        fft_segment = fft(segment, N_FFT);
        custom_spectrogram(:, j) = abs(fft_segment(1:N_FFT / 2 + 1));
    end

    % Time and frequency axes for custom spectrogram
    time_axis = (0:num_segments-1) * step_size / fs;
    freq_axis = (0:N_FFT / 2) * (fs / N_FFT);
    
    T = time_axis;
    F = freq_axis;
    Spec = custom_spectrogram;

end