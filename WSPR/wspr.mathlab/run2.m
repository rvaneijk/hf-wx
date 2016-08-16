pass = 1;
if (pass == 0),
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
            call = C{3}(idx); % reporters call
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
                calldata = call(jdx);
                snrdata = SNR(jdx);
                disdata = distance(jdx);
                azidata = azimuth(jdx);
                powdata = power(jdx);
              else
                tdata = [tdata' time(jdx)']';
                griddata = [griddata' grid(jdx)']';
                calldata = [calldata' call(jdx)']';
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
end
ucalldata = unique(calldata);
ncalldata = size(ucalldata,1);
for i=1:ncalldata,
  idx = find( strcmp(ucalldata(i),calldata) == 1 );
  % fprintf('%10s %5d\n',char(ucalldata(i)),size(idx,1));
  mcalldata(i) = size(idx,1);
end 
[count,jdx] = sort(mcalldata,'descend');
k = 0;
for i=1:ncalldata,
  if (count(i) > 1),
    k = k + 1;
    idx = find( strcmp(ucalldata(jdx(i)),calldata) == 1 );
    md = mean(disdata(idx));  
    fprintf('%10s %5d  %6.1f\n',char(ucalldata(jdx(i))),count(i),md); 
  end
end
kmax = k; k=0; clf; hold on;
for i=1:ncalldata,
  if (count(i) > 1),
    k = k + 1;
    station = char(ucalldata(jdx(i)));
    idx = find( strcmp(calldata,station) == 1 ); 
    plot( doy(idx),disdata(idx),'b.' );
  end
end
hold off;
    