clear;
d = dir('wsprspots-2016-07.csv');
path(path,'C:\Users\Admin\Desktop\WSPR TX\m_map1.4\m_map');
ndir = size(d,1);
k = 0;
offset0 = datenum('2000-1-1 0:0:0') - 730486 + 2451544.5;                % nodig voor EquationOfTime
offset = datenum('2016-1-1 0:0:0')-datenum('2000-1-1 0:0:0') + offset0;  % nodig voor EquationOfTime
maxpower = 40;
for idir = 1:ndir,
    filename = d(idir).name;
    fprintf('Running on filename %s\n',filename);
    finfo = dir(filename);
    fsize = finfo.bytes;
    position = 0;
    nrec=100000;
    fp = fopen(filename);
    while (position < fsize),
      [C,position] = textscan(fp,'%d %d %s %s %f %s %s %s %f %f %f %f %f %s %f',nrec,'Delimiter',',');
      idx = find(strcmp(C{7}(:),'PA1EJO')==1);
      occurence = size(idx,1);
      if (occurence > 0),
        fprintf('advanced %5.1f occurence %4d counter %3d\n',(position/fsize)*100,occurence,k); 
      end
      if (occurence > 0),
        time = C{2}(idx);
        grid = C{4}(idx); % reporters grid
        SNR = C{5}(idx);
        frequency = str2double(C{6}(idx));
        power = C{9}(idx);
        distance = C{11}(idx);
        azimuth = C{12}(idx);
        band = C{13}(idx);
        code = C{15}(idx);
        jdx = find( (code == 0) & (band == 14) & (frequency >= 14.097000) & (frequency <= 14.097200) & (power <= maxpower) );
        if (size(jdx,1) > 0),
          k = k + 1;
          if (k == 1), 
            tdata = time(jdx);
            griddata = grid(jdx);
            snrdata = SNR(jdx);
            disdata = distance(jdx);
            azidata = azimuth(jdx);
            powdata = power(jdx);
          else
            tdata = [tdata' time(jdx)']';
            griddata = [griddata' grid(jdx)']';
            snrdata = [snrdata' SNR(jdx)']';
            disdata = [disdata' distance(jdx)']';
            azidata = [azidata' azimuth(jdx)']'; 
            powdata = [powdata' power(jdx)']';
          end
        end
      end
    end
    fclose(fp);
end
ndate = datenum(1970,1,1,0,0,0) + double(tdata)/86400.0;
doy = ndate - datenum(2016,1,1,0,0,0);
l = 0;
step = 2/24;
for day = floor(min(doy)):step:ceil(max(doy)),
  idx = find( (doy > (day-step/2)) & (doy < (day+step/2)) );
  if (size(idx,1) > 0),
    l = l + 1;
    xdata(l) = day;
    ydata(l,1) = mean(disdata(idx));
    ydata(l,2) = median(disdata(idx));
    ydata(l,3) = max(disdata(idx));
    ydata(l,4) = max(powdata(idx));
    edata(l) = EquationOfTime(day+offset);
  end
end
clf;
%
figure(1);
subplot(4,1,1); bar(xdata,ydata(:,1)); ylabel('mean km');
subplot(4,1,2); bar(xdata,ydata(:,2)); ylabel('median km');
subplot(4,1,3); bar(xdata,ydata(:,3)); ylabel('max km');
subplot(4,1,4); bar(xdata,ydata(:,4)); xlabel('day in year'); ylabel('power');
%
figure(2);
ugriddata = unique(griddata);
ngriddata = size(ugriddata,1);
for i=1:ngriddata,
  [lon,lat] = maidenhead(ugriddata(i));
  x(i) = lon; y(i) = lat;
end 
hold on;
m_proj('miller','lat',[-90 90]);
m_plot(x,y,'.');
m_coast('patch',[.7 1 .7],'edgecolor','none');
m_grid('box','fancy','linestyle','none','backcolor',[.9 .99 1]);
hold off;
%
figure(3);
dayoffset = floor(xdata);
local = (xdata - floor(xdata))*1440 - edata;
h = ydata(:,1);
scatter(local/60,dayoffset,h/10,ones(size(h)),'filled'); 
axis([-2 26 min(dayoffset)-2 max(dayoffset)+2]);

