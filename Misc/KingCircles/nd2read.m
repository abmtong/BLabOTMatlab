function [im_ch1, im_ch2, im_ch3, im_ch4] = nd2read(filename, varargin)
if nargin < 1 || isempty(filename)
    [f p]= uigetfile('*.nd2');
    filename = fullfile(p,f);
end

tic
finfo = nd2finfo(filename);
disp(['analyzing file structure used ', sprintf('%0.2f', toc), ' seconds'])

im_ch1 = zeros(finfo.img_width, finfo.img_height, 'uint16');
im_ch2 = zeros(finfo.img_width, finfo.img_height, 'uint16');
im_ch3 = zeros(finfo.img_width, finfo.img_height, 'uint16');
% if finfo.ch_count == 4 %edit: output 4 channels always [else 0s]
  im_ch4 = zeros(finfo.img_width, finfo.img_height, 'uint16');
% end

fid = fopen(filename, 'r');
fseek(fid, finfo.file_structure(strncmp('ImageDataSeq', ...
  {finfo.file_structure(:).nameAttribute}, 12)).dataStartPos, 'bof');

tic
% Image extracted from ND2 has image width defined by its first dimension.
if finfo.padding_style == 1
  if finfo.ch_count == 4
    for ii = 1: finfo.img_height
        temp = reshape(fread(fid, finfo.ch_count * finfo.img_width, '*uint16'),...
          [finfo.ch_count finfo.img_width]);
        im_ch3(:, ii) = temp(1, :);
        im_ch1(:, ii) = temp(2, :);
        im_ch2(:, ii) = temp(3, :);
        im_ch4(:, ii) = temp(4, :);
        fseek(fid, 2, 'cof');
    end
  else
    for ii = 1: finfo.img_height
        temp = reshape(fread(fid, finfo.ch_count * finfo.img_width, '*uint16'),...
          [finfo.ch_count finfo.img_width]);
        im_ch3(:, ii) = temp(1, :);
        im_ch1(:, ii) = temp(2, :);
        im_ch2(:, ii) = temp(3, :);
        fseek(fid, 2, 'cof');
    end
  end
else
  if finfo.ch_count == 4
    for ii = 1: finfo.img_height
        temp = reshape(fread(fid, finfo.ch_count * finfo.img_width, '*uint16'),...
          [finfo.ch_count finfo.img_width]);
        im_ch1(:, ii) = temp(1, :);
        im_ch2(:, ii) = temp(2, :);
        im_ch3(:, ii) = temp(3, :);
        im_ch4(:, ii) = temp(4, :);
    end
  else
    for ii = 1: finfo.img_height
        temp = reshape(fread(fid, finfo.ch_count * finfo.img_width, '*uint16'),...
          [finfo.ch_count finfo.img_width]);
        im_ch1(:, ii) = temp(1, :);
        im_ch2(:, ii) = temp(2, :);
        im_ch3(:, ii) = temp(3, :);
    end 
  end
end

fclose(fid);

im_ch1 = permute(im_ch1, [2 1]);
im_ch2 = permute(im_ch2, [2 1]);
im_ch3 = permute(im_ch3, [2 1]);
if finfo.ch_count == 4
    im_ch4 = permute(im_ch4, [2 1]);
end
if any(strcmpi(varargin, 'use_ch4'))
  im_ch3 = im_ch4;
end
  

disp(['reading complete image data used ', sprintf('%0.2f', toc), ' seconds'])
end