clear

%% INPUT: select files
Folder = 'C:\Users\crowe\Documents\MATLAB\VNA_measurements\playing_around_to_test_snp_to_csv';
antenna_locations = readmatrix([Folder '/8-antenna positions.csv']);  %origin is defined as the middle of the sample

file_background = 'background_1.s8p';
file_target = '200.s8p';

%% define s-parameter objects
s_background = sparameters([Folder '/' file_background]);
s_target = sparameters([Folder '/' file_target]);

differential = s_target.Parameters - s_background.Parameters;
frequencies = s_background.Frequencies; % assumes background and target have the same frequencies
s_differential = sparameters(differential, frequencies); 

% define set-up
num_ports = s_differential.NumPorts;
num_channels = s_differential.NumPorts^2;

% define channels
channels = zeros(num_channels, 2);
index = 1;
for row = 1:num_ports
    for col = 1:num_ports
        channels(index, 1) = row;
        channels(index, 2) = col;
        index = index + 1;
    end
end

signals = zeros(length(frequencies), num_channels);

%set signals
index = 1;
for row = 1:num_ports
    for col = 1:num_ports
        S_ij_E = squeeze(s_differential.Parameters(row, col, :));  % Extract specific S-parameter for E
        signals(:, index) = S_ij_E;  % Store complex values for E
        index = index + 1;
    end
end

%signals = isolateAntennas(1, num_ports, signals) change the 1 to whichever
%antenna response you want to isolate

% INPUT: MERIT parameters
permittivity=10;  %32 f3    29 f4
phantom_radius = 0.073;  % Radius of the cylinder
phantom_height = 0.08; % per Carlos leave this as an option in .hemisphere

[points, axes_] = merit.domain.hemisphere(phantom_radius, 'no_z', phantom_height, 'resolution', 2e-3);

delays = merit.beamform.get_delays(channels, antenna_locations, ...
   relative_permittivity=permittivity);

img = abs(merit.beamform(signals, frequencies, points, delays, ...
       merit.beamformers.DAS));  %DAS = Delay and Sum, DMAS, also options


%% Display image 
im_slice = merit.domain.img2grid(img, points, axes_{1:2});
figure
imagesc(axes_{1:2},im_slice'); %imagesc(axes_{1:2}, im_slice');
set(gca, 'YDir', 'normal');
axis image;
c = colorbar;
c.Label.String = "Scattering Density";
c.Label.FontSize = 12;
hold on;
xlabel('x (m)');
ylabel('y (m)');

colormap(parula); % or whatever you're using

cmap = colormap;          % get current colormap
set(gca, 'Color', cmap(1,:));  % set background to lowest color (dark blue)

xlim([-0.125 0.125]);
ylim([-0.125 0.125]);
set(gca, 'LooseInset', get(gca, 'TightInset'));


%% Plot antennas
scatter(antenna_locations(:,1), antenna_locations(:,2), 'r', 'filled');

r_offset = 0.0055; % adjust this (in meters) until it looks good

for i = 1:length(antenna_locations)
    x = antenna_locations(i,1);
    y = antenna_locations(i,2);

    % Compute radial direction
    r = sqrt(x^2 + y^2);
    ux = x / r;
    uy = y / r;

    % Offset position
    x_text = x + r_offset * ux;
    y_text = y + r_offset * uy;

    text(x_text, y_text, sprintf('A%d', i), ...
        'Color', 'w', ...
        'FontWeight', 'bold', ...
        'HorizontalAlignment', 'center');
end

%% Display 3D image 
[grid_]= merit.domain.img2grid(img, points);
new_grid_(:,:,1)= grid_;
new_grid_(:,:,2)= grid_;
merit.visualize.display_3D_scan(new_grid_, axes_);

function y = isolateAntennas(a, num_ports, signal_array)
arguments
    a (1,1) double
end
%gets Sij (where i=a, j=a) of signal array
f = 1 + (num_ports+1)*(a - 1);  % eg for 8-antenna 1, 10, 19, 
signal_array(:, [1:f-1,f+1:end]) = 0;
y = signal_array;
end


