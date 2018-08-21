function drawTraces(h)
% left-hand-side plot of functional data

%% inputs
cIX = h.cIX;
gIX = h.gIX;
M = h.M;
stim = h.stim;
numK = h.numK;
clrmap = h.vis.clrmap;
isPlotLines = h.vis.isPlotLines;
isShowTextFunc = h.vis.isShowTextFunc;

Fs = h.dat.ops.imageRate; % Sampling frequency

% init
xv = (1:size(M,2))/Fs;
nTraces = length(cIX);        
% isPlotBehavior = 0;

%% axis setup
axis off;
h_ax = gca;
pos = get(h_ax,'Position'); % [left, bottom, width, height]
% set size of stimulus-bar relative to whole plot
% each stim bar (if applicable) takes up 1 unit, and behavior bar takes up 2.
barratio = 0.025;%  barratio = 0.05;

%% plot main data
        
[nLines,nFrames] = size(M);
%         if isPopout
% if ~isPlotBehavior
    set(h_ax,'Position',[pos(1),pos(2),pos(3),pos(4)*(1-barratio)]);
% else
%     set(h_ax,'Position',[pos(1),pos(2)+pos(4)*barratio*2,pos(3),pos(4)*(1-barratio*3)]);
% end

%         else % in main window, isPlotBehavior is always true
%             % but need to leave extra space for the bottom axis (compared to isPopout)
%             set(h_ax,'Position',[pos(1),pos(2)+pos(4)*barratio*3,pos(3),pos(4)*(1-barratio*4)]);
%         end


switch isPlotLines
    case 0 % draw data as grayscale image
        
        axis ij; axis fill
        %% Prep func data
        im_data = mat2gray(M);
        RGB = repmat(im_data,1,1,3); % make RGB image from grayscale
        
        %         im_stimbar = stim/max(stim);
        %         im = vertcat(im_stimbar,im_data);
        
        %% add vertical color code
        clrmap = vertcat(clrmap,[0,0,0]); % extend colormap to include black

        bwidth = max(round(nFrames/30),1);
        
        %         idx = gIX;
        ix_div = [find(diff(gIX));length(gIX)];
        
        bars = ones(nLines,bwidth);
        if numK>1
            bars(1:ix_div(1),:) = gIX(ix_div(1));
            for i = 2:length(ix_div)
                % paint color
                bars(ix_div(i-1)+1:ix_div(i),:) = gIX(ix_div(i));
            end
        end
        im_bars = reshape(clrmap(bars,:),[size(bars),3]);
        % add a white division margin
        div = ones(nLines,round(bwidth/2),3);
        % put 3 parts together
        im = horzcat(RGB,div,im_bars);
        
        %% plot main figure
        [s1,s2,s3] = size(im);
        
        % (if too few rows, pad to 30 rows with white background)
        nrow_min = 20;
        if s1<nrow_min            
            temp = im;
            im = ones(nrow_min,s2,s3);
            im(1:s1,:,:) = temp;
            s1 = nrow_min;
        end
  
        image(im);
        colormap gray;
        set(gca, 'box', 'off')
        hold on;
        ylim([0.5,s1+1.5]);
        % plot cluster division lines
        plot([0.5,s2+0.5],[0.5,0.5],'k','Linewidth',0.5);
        if numK>1
            for i = 1:length(ix_div)% = numK-1,
                y = ix_div(i)+0.5;
                plot([0.5,s2+0.5],[y,y],'k','Linewidth',0.5);
            end
        end
        
        % label axes
        if ~exist('nCells','var')
            nCells = nLines;
        end
        ylabel(['Number of cells: ' num2str(nCells)]);
        set(gca,'YTick',[],'XTick',[]);
        set(gcf,'color',[1 1 1]);
        
        % write in text labels (numbers corresponding to vertical colorbar)
        x = s2*1.003;
        y_last = 0;
        for i = 1:length(ix_div)
            % avoid label crowding
            margin = 0.015*s1;
            y0 = ix_div(i)+0.5;
            y = max(y_last+margin,y0);
            if i<length(ix_div)
                ynext = ix_div(i+1);
            else
                ynext = y0+margin*2;
            end
            % draw if not squeezed too much away
            if y < y0+margin*2 && y < 0.5*(y0+ynext) %nLines+stimheight-margin,
                if exist('iswrite','var') && iswrite
                    try
                        text(x,y,[num2str(gIX(ix_div(i))) ': ' num2str(rankscore(i))],'HorizontalAlignment','Left','VerticalAlignment','Bottom',...
                            'FontUnits','normalized','FontSize',0.015,'Tag','label');
                    catch
                        disp('rankscore invalid');
                        text(x,y,num2str(gIX(ix_div(i))),'HorizontalAlignment','Left','VerticalAlignment','Bottom',...
                            'FontUnits','normalized','FontSize',0.015,'Tag','label');
                    end
                    
                else
                    text(x,y,num2str(gIX(ix_div(i))),'HorizontalAlignment','Left','VerticalAlignment','Bottom',...
                        'FontUnits','normalized','FontSize',0.015,'Tag','label');
                end
                y_last = y;
            end
        end
        
        % draw scale bar
        xsec = round(max(xv)/10,1,'significant');       
        base_y = s1+1;
        
        x_plot = xsec * Fs;
        plot([0.5,0.5+x_plot],[base_y,base_y],'linewidth',2,'color','k');
        text(0,0,[num2str(xsec),' sec'],'HorizontalAlignment','left','Units','normalized')
        xlabel('sec')
        
        % axis scaling
        xlim([0.5,s2+0.5]);
        ylim([0.5,s1+1.5]);

    case 1 % draw individual traces
        
        pad = 1;        
        
        for ii = 1:nTraces
            % data
            y_n = M(ii,:);
            y_n = y_n/(max(y_n)-min(y_n));
            
            % color
            igroup = gIX(ii);
            clr = clrmap(igroup,:)*0.9;
            
            % plot
%             plot(y_n - pad*(ii-1),'color',clr);%[0.5,0.5,0.5])
            plot(xv,y_n - pad*(ii-1),'color',clr);%[0.5,0.5,0.5])
%             axis fill
            
            % draw text on left of traces
            if isShowTextFunc && nTraces<100
                str = num2str(cIX(ii));
                text(0, 0.2- pad*(ii-1),str,'HorizontalAlignment','right','color',[0.5,0.5,0.5]);
            end
        end
        
        % draw scale bar
        xsec = round(max(xv)/10,1,'significant');       
        base_y = -pad*nTraces-1;
        plot([min(xv),min(xv)+xsec],[base_y,base_y],'linewidth',2,'color','k');
        text(0,0,[num2str(xsec),' sec'],'HorizontalAlignment','left','Units','normalized')
        xlabel('sec')
        
        % axis scaling
        xlim([min(xv),max(xv)]);
        ylim([base_y-1,2])
end
                
%% add number of ROI's
if h.cellvsROI
    str = ['Number of cells: ' num2str(nTraces)];
else
    str = ['Number of ROI''s: ' num2str(nTraces)];
end
text(0.5,0,str,'HorizontalAlignment','center','Units','normalized')

%% Draw stim bars
axes('Units','pixels','Position',[pos(1),pos(2)+pos(4)*(1-barratio),pos(3),pos(4)*barratio]);

roughhalfbarheight = 100;
[stimbar_,halfbarheight] = getStimBar(roughhalfbarheight,stim,h.timeInfo.nElm);

% pad with margin on right to fit combo-image size
if ~isPlotLines
    barlength = size(im,2);
    xlim([0.5,s2+0.5]);
else
    barlength = size(stim,2);
    xlim([0.5,barlength+0.5]);
end
stimbar = ones(halfbarheight*2,barlength,3);
stimbar(:,1:nFrames,:) = stimbar_(:,1:nFrames,:); % crop to size

% top axis

image(stimbar);axis off;hold on;
plot([0,length(stim)+0.5],[1,1],'k','Linewidth',0.5); % plot top border
plot([0+0.5,0+0.5],[0,size(stimbar,1)],'k','Linewidth',0.5); % plot left/right border
plot([length(stim)+0.5,length(stim)+0.5],[0,size(stimbar,1)],'k','Linewidth',0.5);

% bottom axis
%         if ~isPopout % plot stimbar in the bottom too
%             axes('Position',[pos(1),pos(2)+pos(4)*barratio*2,pos(3),pos(4)*barratio]);
%             image(stimbar);axis off;hold on;
%             plot([1,length(stim)],[size(stimbar,1),size(stimbar,1)],'k','Linewidth',0.5); % plot bottom border
%             plot([0.5,0.5],[0,size(stimbar,1)],'k','Linewidth',0.5); % plot left border
%             plot([length(stim),length(stim)],[0,size(stimbar,1)],'k','Linewidth',0.5); % plot right border
%         end


end