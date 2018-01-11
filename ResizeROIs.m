function h = ResizeROIs(h, spatscale)

rsc = h.sc / spatscale;

for k = 1:numel(h.ROI)
    nxS = floor(h.nX{k} / spatscale);
    nyS = floor(h.nY{k} / spatscale);

    for j = 1:numel(h.ROI{k})
        if ~isempty(h.ROI{k}{j})
            h.ROI{k}{j} = h.ROI{k}{j} * rsc;
            h.ROI{k}{j} = OnScreenROI(h.ROI{k}{j}, nxS, nyS);
            
        end
    end
    for j = 1:numel(h.eROI{k})
        if ~isempty(h.eROI{k}{j})
            h.eROI{k}{j} = h.eROI{k}{j} * rsc;
            h.eROI{k}{j} = OnScreenROI(h.eROI{k}{j}, nxS, nyS);
        end
    end
end