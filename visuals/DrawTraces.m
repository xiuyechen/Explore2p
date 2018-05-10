function DrawTraces(h)
axis off
cIX_abs = h.cIX_abs;
gIX = h.gIX;


if length(cIX_abs)<200 % draw individual traces
    
    
    pad = 1;
    
    Fs = 15.3;            % Sampling frequency
    xv = (1:h.t_stop-h.t_start+1)/Fs;
    isdrawtext = length(cIX_abs)<50;
    for i = 1:length(cIX_abs)
        ichosen = cIX_abs(i);
        igroup = gIX(i);
        
        F = [];
        Fneu = [];
        for j = 1:numel(h.dat.Fcell)
            F    = cat(2, F, h.dat.Fcell{j}(ichosen, :));
            Fneu = cat(2, Fneu, h.dat.FcellNeu{j}(ichosen, :));
        end
        
        y = double(F(h.t_start:h.t_stop));%my_conv_local(medfilt1(double(F), 3), 3);
        y_m = y-mean(y);
        y_n = y_m/(max(y_m)-min(y_m)); % divide by range for visualization... not df/f! % not using zscore(y);
        
        %     if isempty(h.gIX)
        clr = h.clrmap(igroup,:)*0.9;
        %  clr_hsv = rgb2hsv(clr);
        %  clr = hsv2rgb(clr_hsv(1),clr_hsv(2),clr_hsv(3)*0.9);
        %        clr = squeeze(hsv2rgb(h.clrmap(igroup),1,0.8));
        %     else
        %         % place holder
        %         clr = squeeze(hsv2rgb(h.clrmap(ichosen),1,0.8));
        %         % use color maps
        %
        %     end
        
        plot(xv,y_n - pad*(i-1),'color',clr);%[0.5,0.5,0.5])
        axis tight
        if isdrawtext
            text(-1, 0.2- pad*(i-1),num2str(i),'HorizontalAlignment','right','color',[0.5,0.5,0.5]);
        end
    end
    % % label: number of ROI's
    % text(-1, 0.2- pad*(i-1),num2str(length(cIX)),'HorizontalAlignment','right','color',[0.5,0.5,0.5]);
    
    % draw scale bar
    base_y = -pad*length(cIX_abs)-1;
    plot([0,10],[base_y,base_y],'linewidth',2,'color','k');
    text(0,0,'10 sec','HorizontalAlignment','center','Units','normalized')
    % text(2.5,base_y-1.5,'10 sec','HorizontalAlignment','center')
    xlabel('sec')
    ylim([base_y-1,2])
    
    % add number of ROI's
    str = ['Number of ROI''s: ' num2str(length(cIX_abs))];
    % xl = xlim; % draw this line in the middle of the axes
    text(0.5,0,str,'HorizontalAlignment','center','Units','normalized')
    % text((xl(2)-xl(1))/2,base_y-1.5,str)
    
    
else
     ichosen = cIX_abs;
        F = [];
        Fneu = [];
        for j = 1:numel(h.dat.Fcell)
            F    = cat(2, F, h.dat.Fcell{j}(ichosen, :));
            Fneu = cat(2, Fneu, h.dat.FcellNeu{j}(ichosen, :));
        end
        imagesc(F);colormap(gray)
end
end