
%Select Images from the folder and perform median filtering?
unfilter_image = imread("middleimage2.jpg");

%APPLY THE FILTER TO THREE SECTIONS OF THE IMAGE DIFFERENTLY

%Split the image into three sections (top to bottom)
Height = size(unfilter_image, 1);
Cut1 = 150;                 % row where the first section ends
Cut2 = 210;                 % row where the second section ends
Section1 = unfilter_image(1:Cut1, :, :);
Section2 = unfilter_image(Cut1+1:Cut2, :, :);
Section3 = unfilter_image(Cut2+1:Height, :, :);

%Filter each section with its own parameters
%                                        Image     Kvert Khor Threshold MinChannels Density_size Max_density
[Filtered1, Scratch1, Raw1] = filtering_function(Section1, 5, 5, 30, 1, 10, 0.6);
[Filtered2, Scratch2, Raw2] = filtering_function(Section2, 5, 5, 10, 2, 30, 0.35);
[Filtered3, Scratch3, Raw3] = filtering_function(Section3, 5, 5, 40, 1, 5, 0.6);

%Put the three sections back together
Final_filtered = [Filtered1; Filtered2; Filtered3];
Scratch_mask = [Scratch1; Scratch2; Scratch3];
Raw_mask = [Raw1; Raw2; Raw3];

%Show the unfiltered and filtered images side by side
figure;
subplot(1,3,1);
imshow(unfilter_image);
yline([Cut1 Cut2], "c", "LineWidth", 1.5);   % shows where the sections split
title("Unfiltered");
subplot(1,3,2);
imshow(cat(3, Scratch_mask, Raw_mask & ~Scratch_mask, zeros(size(Scratch_mask))));
title("Replaced (red) / Rejected as too dense (green)");
subplot(1,3,3);
imshow(uint8(Final_filtered));
title("Filtered");

function [Final_filtered, Scratch_mask, Raw_mask] = filtering_function(unfilter_image, Kernel_vert, Kernel_hor, Threshold, MinChannels, Density_size, Max_density)
    %Run through every column and row
    %Correct for the colours separately
    for channelIndex = 1:size(unfilter_image, 3)
        [filtered_image, flag_image] = median_function(unfilter_image, Kernel_vert, Kernel_hor, channelIndex, Threshold);
        if channelIndex == 1
            filtered_red = filtered_image;
            flag_red = flag_image;
        elseif channelIndex == 2
            filtered_green = filtered_image;
            flag_green = flag_image;
        elseif channelIndex == 3
            filtered_blue = filtered_image;
            flag_blue = flag_image;
        end
    end

    % Pixel is a scratch only if enough channels flagged it
    Scratch_mask = (double(flag_red) + double(flag_green) + double(flag_blue)) >= MinChannels;

    % Reject flags in areas where too many pixels are flagged
    Raw_mask = Scratch_mask;    % keep the channel detection
    Density = conv2(double(Raw_mask), ones(Density_size)/Density_size^2, "same");
    Scratch_mask = Raw_mask & (Density <= Max_density);

    % Start from the original image and replace only the masked pixels, in every channel
    Final_filtered = double(unfilter_image);
    Red = Final_filtered(:,:,1);   Red(Scratch_mask)   = filtered_red(Scratch_mask);
    Green = Final_filtered(:,:,2); Green(Scratch_mask) = filtered_green(Scratch_mask);
    Blue = Final_filtered(:,:,3);  Blue(Scratch_mask)  = filtered_blue(Scratch_mask);
    Final_filtered = cat(3, Red, Green, Blue);
end

%Define function for the median kernel filtering
function [filtered, flagged] = median_function(Image, Kernel_vert, Kernel_hor, Channel, Threshold)
    %Create the filtered image In one colour
    filtered = zeros(size(Image, 1), size(Image, 2));
    flagged = false(size(Image, 1), size(Image, 2));
    %Check the Kernel doesn't overextend and perform iteration
    for Current_index_ver = 1:size(Image, 1)
        for Current_index_hor = 1:size(Image, 2)
            if Current_index_hor - Kernel_hor < 1
                currentColumn = 1+Kernel_hor;
            elseif Current_index_hor + Kernel_hor > size(Image, 2)
                currentColumn = size(Image, 2) - Kernel_hor;
            else
                currentColumn = Current_index_hor;
            end
            if Current_index_ver - Kernel_vert < 1
                currentRow = 1+Kernel_vert;
            elseif Current_index_ver + Kernel_vert > size(Image, 1)
                currentRow = size(Image, 1) - Kernel_vert;
            else
                currentRow = Current_index_ver;
            end
            rowRange = (currentRow-Kernel_vert):(currentRow+Kernel_vert);
            columnRange = (currentColumn-Kernel_hor):(currentColumn+Kernel_hor);
            neighborhood = double(Image(rowRange, columnRange, Channel));
            Median_val = median(neighborhood, "all");
            filtered(Current_index_ver, Current_index_hor) = Median_val;

            %Flag the pixel if it differs a lot from its median
            Original_val = double(Image(Current_index_ver, Current_index_hor, Channel));
            flagged(Current_index_ver, Current_index_hor) = abs(Original_val - Median_val) > Threshold;
        end
    end
end

%TO DO CHECK IF WE CAN ADD A WAY OF INSTEAD OF TAKING THE AVERAGE TAKE THE
%REAL MEDIAN