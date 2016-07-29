function [lon,lat] = maidenhead(str)
%
% maidenhead string to lat lon
%
string = char(str);
lstring = size(string,2);
if ((lstring ~= 4) & (lstring ~= 6)),
  lat = -999;
  lon = -999;
  return
end
%
code = upper(string);
lon0 = double(int32(code(1)) - int32('A'))*20-180;
lat0 = double(int32(code(2)) - int32('A'))*10-90;
lon1 = double(int32(code(3)) - int32('0'))*2;
lat1 = double(int32(code(4)) - int32('0'))*1;
lat = lat0+lat1;
lon = lon0+lon1;
if (lstring == 6),
  lat2 = double(int32(code(6)) - int32('A'))*2.5/60; 
  lon2 = double(int32(code(5)) - int32('A'))*5.0/60;
  lon = lon + lon2;
  lat = lat + lat2;
end
