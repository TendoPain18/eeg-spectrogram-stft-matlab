

classdef Pre_Processer
   methods(Static)
       
       function [good_data, seizure_data] = get_good_and_bad_data(summary_file, fileNames, good_index, bad_index, channels, fs)
            % Function to load and process seizure data, returning good and bad data matrices
            % Inputs:
            %   summary_file - Name of the summary file containing seizure time information
            %   fileNames - Cell array of file names for the data files
            %   good_index - Index for the good data to extract
            %   bad_index - Index for the bad data to extract
            % Outputs:
            %   good_data - The good data matrix (of size m x 29)
            %   bad_data - The bad data matrix (of size m x 29)
        
            % Load the data files
            data = loadAndExtractMatrices(fileNames);
        
            % Load the summary data
            summary_data = loadSummaryData(summary_file);
        
            % Extract seizure times from the summary data for a given file name
            file_name = fileNames{bad_index};
            split_parts = split(file_name, '\');
            last_part = split_parts{end};
            file_name = erase(last_part, '_data.mat');
            seizure_times = parseSeizureTimes(summary_data, file_name);
        
            % Extract seizure data for bad data
            seizure_dict = extractSeizureData(seizure_times, data(bad_index), fs);
            seizure_data = concatenateSeizureData(seizure_dict);
        
            % Extract the good data and ensure it has the same number of rows as seizure_data
            good_data = data(good_index);
            good_data = good_data{1};
            good_data = good_data(1:size(seizure_data, 1), :);  % Match the number of rows

            good_data = good_data(:, channels);
            seizure_data = seizure_data(:, channels);
            
            good_data(isnan(good_data)) = 0;
            seizure_data(isnan(seizure_data)) = 0;
            
            good_data = [mean(good_data, 2)];
            seizure_data = [mean(seizure_data, 2)];
        end

   end
end

function data = loadAndExtractMatrices(fileNames)
    % Ensure input is a cell array of file names
    if ~iscell(fileNames)
        error('Input must be a cell array of file names.');
    end

    % Initialize a cell array to hold the data
    data = cell(1, numel(fileNames));

    % Loop through each file to load data
    for i = 1:numel(fileNames)
        fileData = load(fileNames{i});
        
        % Extract the first field name
        fieldNames = fieldnames(fileData);
        if isempty(fieldNames)
            error('File %s contains no data.', fileNames{i});
        end
        
        % Store the data in the cell array
        data{i} = fileData.(fieldNames{1});
    end
end


function summary_data = loadSummaryData(summary_file)
    fileID = fopen(summary_file, 'r');
    
    if fileID == -1
        error('Failed to open the summary file: %s', summary_file);
    end
    
    summary_data = textscan(fileID, '%s', 'Delimiter', '\n');
    fclose(fileID);
end


function seizure_times = parseSeizureTimes(summary_data, file_name)
    % Function to parse seizure times from summary data for a given file name
    % Inputs:
    %   summary_data - Cell array containing lines of text from the summary
    %   file_name    - Target file name to extract seizure times for
    % Outputs:
    %   seizure_times - Nx2 array of seizure start and end times in seconds

    % Initialize seizure times array
    seizure_times = [];

    % Helper function to convert hh:mm:ss to seconds
    convertToSeconds = @(timeStr) sum(sscanf(timeStr, '%d:%d:%d') .* [3600; 60; 1]);

    % Loop through each line of summary_data
    for i = 1:length(summary_data{1})
        line = summary_data{1}{i};

        % Check if the line contains the target file name
        if contains(line, ['File Name: ', file_name])
            j = i + 1; % Start reading subsequent lines
            while j <= length(summary_data{1}) && ~isempty(summary_data{1}{j})
                current_line = summary_data{1}{j};

                % Extract seizure start times
                if contains(current_line, 'Start Time:')
                    start_time_text = strtrim(extractAfter(current_line, 'Start Time:'));
                    if contains(start_time_text, ':')
                        start_time = convertToSeconds(start_time_text);
                    elseif contains(start_time_text, 'seconds')
                        start_time = str2double(regexp(start_time_text, '\d+', 'match', 'once'));
                    end

                % Extract seizure end times
                elseif contains(current_line, 'End Time:')
                    end_time_text = strtrim(extractAfter(current_line, 'End Time:'));
                    if contains(end_time_text, ':')
                        end_time = convertToSeconds(end_time_text);
                    elseif contains(end_time_text, 'seconds')
                        end_time = str2double(regexp(end_time_text, '\d+', 'match', 'once'));
                    end

                    % Append the seizure times to the array
                    seizure_times = [seizure_times; start_time, end_time];
                end

                % Move to the next line
                j = j + 1;
            end
        end
    end
end


function seizure_dict = extractSeizureData(seizure_times, data_matrix, sampling_rate)
    % Function to extract seizure data from a larger matrix and create a dictionary
    % Inputs:
    %   seizure_times - Nx2 matrix where each row is [start_time, end_time] in seconds
    %   big_matrix    - Larger matrix of size Mx29 (data source)
    %   sampling_rate - Sampling rate in Hz (e.g., 256 Hz)
    % Outputs:
    %   seizure_dict  - A dictionary containing seizure data for each entry

    % Initialize the dictionary as a structure array
    seizure_dict = struct('start_time', {}, 'end_time', {}, 'date', {}, 'data', {});
    data_matrix = data_matrix{1};

    % Loop through seizure times starting from the second row
    for i = 2:size(seizure_times, 1)
        % Get start and end times in samples
        start_sample = round((seizure_times(i, 1) - 1) * sampling_rate) + 1; % MATLAB indexing starts at 1
        end_sample = round((seizure_times(i, 2) - 1) * sampling_rate);

        % Extract data from the larger matrix
        extracted_data = data_matrix(start_sample:end_sample, :);

        % Create the entry in the dictionary
        seizure_entry.start_time = seizure_times(i, 1);
        seizure_entry.end_time = seizure_times(i, 2);
        seizure_entry.date = datestr(now, 'yyyy-mm-dd'); % Placeholder for the date
        seizure_entry.data = extracted_data;

        % Append to the dictionary
        seizure_dict(end + 1) = seizure_entry;
    end
end


function concatenated_data = concatenateSeizureData(seizure_dict)
    % Function to concatenate all seizure data from the seizure_dict
    % Inputs:
    %   seizure_dict - A struct containing seizure data with fields:
    %                  - data: The extracted seizure data matrix
    %                  - start_times: A vector of start times for each seizure
    %                  - end_times: A vector of end times for each seizure
    %                  - date: The date of the seizure data extraction
    % Outputs:
    %   concatenated_data - A single matrix containing all seizure data concatenated

    % Initialize the matrix for concatenated seizure data
    concatenated_data = [];

    % Loop through each seizure and concatenate its data
    x = size(seizure_dict, 2);
    for i = 1:x
        seizure_data = seizure_dict(i).data;
        % Extract the seizure data and append to the result
        concatenated_data = [concatenated_data; seizure_data];
    end

    % Display the size of the concatenated data
    fprintf('Concatenated seizure data size: %d rows, %d columns\n', size(concatenated_data, 1), size(concatenated_data, 2));
end


% seizure_times = [
%     0    0;
%     1   2;
%     2   3;
%     3   4;
%     1   3;
%     100  110;
%     120  130
% ];

