function importFlow(infp)

if nargin < 1
    [f, p] = uigetfile('*.csv');
    if ~p
        return
    end
    infp = fullfile(p,f);
end
%Maybe do something for batch processing...




% Open a file dialog for the user to select CSV files
[fileNames, folderPath] = uigetfile('*.csv', 'Select CSV files', 'MultiSelect', 'on');

% Check if the user canceled the dialog or selected at least one file
if isequal(fileNames, 0)
    disp('No files selected. Import canceled.');
else
    % If the user selected files, fileNames can be either a character array or a cell array
    
    % Convert fileNames to a cell array if it's not already
    if ischar(fileNames)
        fileNames = {fileNames};
    end
    
    % Initialize cell arrays to store data, file names, col8Data, and col11Data
    fileDataWithNames = cell(1, numel(fileNames));
    muValues = zeros(1, numel(fileNames)); % Initialize an array to store mu values
    sigmaValues = zeros(1, numel(fileNames)); % Initialize an array to store sigma values

    % Loop through each selected CSV file
    for i = 1:numel(fileNames)
        % Get the current file name
        fileName = fileNames{i};
        
        % Build the full file path
        filePath = fullfile(folderPath, fileName);
        
        % Import data from the CSV file using the 'readtable' function
        data = readtable(filePath); % Modify this line if needed
        
        % Extract column 8 and column 11 data and convert to numeric arrays
        col8 = table2array(data(:, 8));
        col11 = table2array(data(:, 11));
        
        % Store data, file name, col8 data, and col11 data together
        fileDataWithNames{i} = struct('FileName', fileName, 'Col8Data', col8, 'Col11Data', col11);
        
        % Filter out Inf and -Inf values in col8_divided_by_col11
        col8_divided_by_col11 = col8 ./ col11;
        col8_divided_by_col11(isinf(col8_divided_by_col11) | -isinf(col8_divided_by_col11)) = NaN;

        % Attempt to fit a bimodal Gaussian distribution to col8
        try
            options = statset('Display', 'off');
            pd_col8 = fitgmdist(col8, 2, 'Options', options); % Fit with 2 components (bimodal)
            mu_col8 = pd_col8.mu;
            sigma_col8 = sqrt(pd_col8.Sigma);
            
            % Store mu and sigma values
            muValues(i) = mu_col8(1); % Store the first mu value
            sigmaValues(i) = sigma_col8(1); % Store the first sigma value
        catch
            % If bimodal fitting fails, fit a unimodal Gaussian distribution
            pd_col8 = fitdist(col8, 'Normal');
            mu_col8 = pd_col8.mu;
            sigma_col8 = pd_col8.sigma;
            
            % Store mu and sigma values
            muValues(i) = mu_col8;
            sigmaValues(i) = sigma_col8;
        end
    end

    % Loop through the imported data and display histograms, Gaussian fits, and Q-Q plots for each file
    for i = 1:numel(fileDataWithNames)
        dataWithNames = fileDataWithNames{i};
        
        % Extract data, file name, col8 data, and col11 data
        col8 = dataWithNames.Col8Data;
        col11 = dataWithNames.Col11Data;
        fileName = dataWithNames.FileName;

        % Create a new figure for each file
        figure;
        
        % Display the file name above the figure
        annotation('textbox', [0.1, 0.92, 0.8, 0.05], 'String', ['File Name: ', fileName], 'EdgeColor', 'none');
        
        % Plot histogram of column 8 in the first subplot with a logarithmic x-axis
        subplot(3, 2, 1);
        [counts, binEdges] = histcounts(col8, 100);
        histfit(col8, 100); % Fit a unimodal Gaussian
        title('eGFP channel');
        set(gca, 'xscale', 'log'); % Set x-axis to logarithmic scale
        xlim([0.01, 10^6]); % Adjust the x-axis limits (start from 0.01)
        
        % Attempt to fit a bimodal Gaussian distribution to col8
        try
            options = statset('Display', 'off');
            pd_col8 = fitgmdist(col8, 2, 'Options', options); % Fit with 2 components (bimodal)
            mu_col8 = pd_col8.mu;
            sigma_col8 = sqrt(pd_col8.Sigma);
            
            % Plot the fitted bimodal Gaussian distributions
            x = linspace(min(col8), max(col8), 1000);
            y1 = pdf(pd_col8, x') * (binEdges(2) - binEdges(1)) * numel(col8);
            y2 = pdf(pd_col8, x') * (binEdges(2) - binEdges(1)) * numel(col8);
            y1(x <= mu_col8(1)) = NaN;
            y2(x > mu_col8(1)) = NaN;
            hold on;
            plot(x, y1, 'r', 'LineWidth', 2);
            plot(x, y2, 'b', 'LineWidth', 2);
            hold off;

            % Display mu and sigma values for bimodal fit
            text(0.7, 0.8, ['\mu1 = ', num2str(mu_col8(1))], 'Units', 'normalized', 'FontSize', 10, 'Color', 'r');
            text(0.7, 0.7, ['\sigma1 = ', num2str(sigma_col8(1))], 'Units', 'normalized', 'FontSize', 10, 'Color', 'r');
            text(0.7, 0.6, ['\mu2 = ', num2str(mu_col8(2))], 'Units', 'normalized', 'FontSize', 10, 'Color', 'b');
            text(0.7, 0.5, ['\sigma2 = ', num2str(sigma_col8(2))], 'Units', 'normalized', 'FontSize', 10, 'Color', 'b');
        catch
            % If bimodal fitting fails, fit a unimodal Gaussian distribution
            pd_col8 = fitdist(col8, 'Normal');
            mu_col8 = pd_col8.mu;
            sigma_col8 = pd_col8.sigma;

            % Display the fitted Gaussian parameters
            text_str = sprintf('\\mu = %f, \\sigma = %f', mu_col8, sigma_col8);
            text(0.7, 0.8, text_str, 'Units', 'normalized', 'FontSize', 10, 'Color', 'r');
        end

        % Create a Q-Q plot for col8
        subplot(3, 2, 2);
        qqplot(col8);
        title('Q-Q Plot for eGFP channel');
        
        % Plot histogram of column 11 in the second subplot with a logarithmic x-axis
        subplot(3, 2, 3);
        [counts, binEdges] = histcounts(col11, 100);
        histfit(col11, 100); % Fit a unimodal Gaussian
        title('mCherry channel');
        set(gca, 'xscale', 'log'); % Set x-axis to logarithmic scale
        xlim([0.01, 10^6]); % Adjust the x-axis limits (start from 0.01)

        % Attempt to fit a bimodal Gaussian distribution to col11
        try
            pd_col11 = fitgmdist(col11, 2, 'Options', options); % Fit with 2 components (bimodal)
            mu_col11 = pd_col11.mu;
            sigma_col11 = sqrt(pd_col11.Sigma);
            
            % Plot the fitted bimodal Gaussian distributions
            x = linspace(min(col11), max(col11), 1000);
            y1 = pdf(pd_col11, x') * (binEdges(2) - binEdges(1)) * numel(col11);
            y2 = pdf(pd_col11, x') * (binEdges(2) - binEdges(1)) * numel(col11);
            y1(x <= mu_col11(1)) = NaN;
            y2(x > mu_col11(1)) = NaN;
            hold on;
            plot(x, y1, 'r', 'LineWidth', 2);
            plot(x, y2, 'g', 'LineWidth', 2);
            hold off;
            text(0.7, 0.8, ['\mu1 = ', num2str(mu_col11(1))], 'Units', 'normalized', 'FontSize', 10, 'Color', 'r');
            text(0.7, 0.7, ['\sigma1 = ', num2str(sigma_col11(1))], 'Units', 'normalized', 'FontSize', 10, 'Color', 'r');
            text(0.7, 0.6, ['\mu2 = ', num2str(mu_col11(2))], 'Units', 'normalized', 'FontSize', 10, 'Color', 'g');
            text(0.7, 0.5, ['\sigma2 = ', num2str(sigma_col11(2))], 'Units', 'normalized', 'FontSize', 10, 'Color', 'g');
        catch
            % If bimodal fitting fails, fit a unimodal Gaussian distribution
            pd_col11 = fitdist(col11, 'Normal');
            mu_col11 = pd_col11.mu;
            sigma_col11 = pd_col11.sigma;

            % Display the fitted Gaussian parameters
            text_str = sprintf('\\mu = %f, \\sigma = %f', mu_col11, sigma_col11);
            text(0.7, 0.8, text_str, 'Units', 'normalized', 'FontSize', 10, 'Color', 'r');
        end
        
        % Create a Q-Q plot for col11
        subplot(3, 2, 4);
        qqplot(col11);
        title('Q-Q Plot for mCherry channel');
        
        % Plot histogram of column 8 divided by column 11 in the fifth subplot
        subplot(3, 2, 5);
        [counts, binEdges] = histcounts(col8_divided_by_col11, 100);
        
        % Attempt to fit a bimodal Gaussian distribution to col8_divided_by_col11
        try
            pd_col8_divided_by_col11 = fitgmdist(col8_divided_by_col11, 2, 'Options', options); % Fit with 2 components (bimodal)
            mu_col8_divided_by_col11 = pd_col8_divided_by_col11.mu;
            sigma_col8_divided_by_col11 = sqrt(pd_col8_divided_by_col11.Sigma);
            
            % Plot the fitted bimodal Gaussian distributions
            x = linspace(min(col8_divided_by_col11), max(col8_divided_by_col11), 1000);
            y1 = pdf(pd_col8_divided_by_col11, x') * (binEdges(2) - binEdges(1)) * numel(col8_divided_by_col11);
            y2 = pdf(pd_col8_divided_by_col11, x') * (binEdges(2) - binEdges(1)) * numel(col8_divided_by_col11);
            y1(x <= mu_col8_divided_by_col11(1)) = NaN;
            y2(x > mu_col8_divided_by_col11(1)) = NaN;
            hold on;
            plot(x, y1, 'r', 'LineWidth', 2);
            plot(x, y2, 'g', 'LineWidth', 2);
            hold off;
            
            % Store mu and sigma values
            muValues(i) = mu_col8_divided_by_col11(1); % Store the first mu value
            sigmaValues(i) = sigma_col8_divided_by_col11(1); % Store the first sigma value
        catch
            % If bimodal fitting fails, fit a unimodal Gaussian distribution
            pd_col8_divided_by_col11 = fitdist(col8_divided_by_col11, 'Normal');
            mu_col8_divided_by_col11 = pd_col8_divided_by_col11.mu;
            sigma_col8_divided_by_col11 = pd_col8_divided_by_col11.sigma;
            
            % Store mu and sigma values
            muValues(i) = mu_col8_divided_by_col11;
            sigmaValues(i) = sigma_col8_divided_by_col11;
        end
        
        % Display the fitted Gaussian parameters
        text_str = sprintf('\\mu = %f, \\sigma = %f', mu_col8_divided_by_col11, sigma_col8_divided_by_col11);
        text(0.7, 0.8, text_str, 'Units', 'normalized', 'FontSize', 10, 'Color', 'r');
        
        % Create a Q-Q plot for col8_divided_by_col11
        subplot(3, 2, 6);
        qqplot(col8_divided_by_col11);
        title('Q-Q Plot for Column 8 / Column 11');
        
        % Add a title for the current file
        sgtitle(['Histogram, Gaussian Fits, and Q-Q Plot Analysis for File: ', fileName]);
        
        % Pause to display the figure for each file (you can adjust this)
        pause(1);
    end
    
    % Display mu and sigma values for each file
    for i = 1:numel(fileNames)
        fprintf('File: %s, mu: %f, sigma: %f\n', fileNames{i}, muValues(i), sigmaValues(i));
    end
end

