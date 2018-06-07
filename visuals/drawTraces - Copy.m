function drawTraces(h)
% left-hand-side plot of functional data

%% inputs
cIX_abs = h.cIX_abs;
gIX = h.gIX;
cIX = h.cIX;
M = h.M;
stim = h.stim;
clrmap = h.vis.clrmap;
isPlotLines = h.vis.isPlotLines;
isShowTextFunc = h.vis.isShowTextFunc;

%% main
axis off;
switch isPlotLines
    case 0 % draw data as grayscale image
        % normalize        
        im_data = mat2gray(M);
        im_stimbar = stim/max(stim);
        im = vertcat(im_stimbar,im_data);
        
        % plot
        imagesc(im);
        axis ij;
        colormap(gray);
        axis tight
    case 1 % draw individual traces
        pad = 1;        
        Fs = 15.3; % Sampling frequency
        xv = (1:size(M,2))/Fs;        
        
        for ii = 1:length(cIX_abs)            
            % data
            y_n = M(ii,:);
            y_n = y_n/(max(y_n)-min(y_n));
            
            % color
            igroup = gIX(ii);
            clr = clrmap(igroup,:)*0.9;
            
            % plot
            plot(xv,y_n - pad*(ii-1),'color',clr);%[0.5,0.5,0.5])
            axis tight
            
            % draw text on left of traces
            if isShowTextFunc && length(cIX_abs)<100            
                str = num2str(cIX(ii));
                text(-1, 0.2- pad*(ii-1),str,'HorizontalAlignment','right','color',[0.5,0.5,0.5]);
            end
        end        
        
        % draw scale bar
        base_y = -pad*length(cIX_abs)-1;
        plot([0,10],[base_y,base_y],'linewidth',2,'color','k');
        text(0,0,'10 sec','HorizontalAlignment','center','Units','normalized')        
        xlabel('sec')
        ylim([base_y-1,2])
        
        % add number of ROI's
        str = ['Number of ROI''s: ' num2str(length(cIX_abs))];        
        text(0.5,0,str,'HorizontalAlignment','center','Units','normalized')        
        
end
end