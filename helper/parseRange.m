function range = parseRange(str)
str = strrep(str,':','-'); % e.g. str= '1,3,5:8';
C = textscan(str,'%d','delimiter',{',',';'});
m = C{:};
range = [];
for i = 1:length(m),
    if m(i)>=0,
        range = [range,m(i)];
    else % have '-'sign,
        range = [range,m(i-1)+1:-m(i)];
    end
end

if size(range,1)<size(range,2)
    range = range';
end
range = double(range);
end