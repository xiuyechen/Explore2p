function h = setCellvsROI(h)
if h.cellvsROI
    h.IsChosen = h.IsCell;
    if ~isempty(h.hfig)
        set(h.gui.cellRange,'BackgroundColor',[1,1,0.8]);
        set(h.gui.ROIrange,'BackgroundColor',[1,1,1]);
        set(h.gui.isCellvsROI,'Checked','on');
    end
else
    h.IsChosen = (1:h.nROIs)';
    if ~isempty(h.hfig)
        set(h.gui.cellRange,'BackgroundColor',[1,1,1]);
        set(h.gui.ROIrange,'BackgroundColor',[1,1,0.8]);
        set(h.gui.isCellvsROI,'Checked','off');
    end
end
end