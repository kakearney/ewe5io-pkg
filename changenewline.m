function changenewline(oldfile, newfile)
%CHANGENEWLINE Replaces newline characters with carriage returns
%
% changenewline(oldfile, newfile)
%
% This function creates a copy of a file, replacing all newline (\n)
% characters with carriage returns (\r).  Certain Windows-based programs
% (e.g Notepad, EwE) do not recognize the newline character properly.
%
% Input variables:
%
%   oldfile: name of original file
%
%   newfile: name of new file

% Copyright 2007 Kelly Kearney


% Method 1

fid1 = fopen(oldfile, 'rt');
fid2 = fopen(newfile, 'wt');


while 1
    old = fgets(fid1);
    if old == -1
        break
    else
        new = regexprep(old, '\n', '\r');
        fprintf(fid2, new);
    end
end

fclose(fid1);
fclose(fid2);

% Method 2

% fid3 = fopen(oldfile, 'rt');
% a = textscan(fid3, '%s', 'Delimiter', '\n');
% a = a{1};
% fclose(fid3);
% 
% 
% fid4 = fopen(newfile2, 'wt');
% for iline = 1:length(a)
%     fprintf(fid4, '%s\r\n', a{iline});
% end


