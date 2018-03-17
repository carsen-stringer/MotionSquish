% plot full face frame and selected ROI

function PlotROI(h)

k = h.whichfile;
tstr = {'pupil 1','pupil 2','whisker','other ROI'};

% smoothing constants
sc = h.sc;

indROI = h.indROI;

axes(h.axes4);

colormap('gray');


frames = zeros(h.vr{k}.Height, h.vr{k}.Width, 3, 'uint8');

if h.cframe < 2
    h.vr{k}.currentTime = h.vr{k}.FrameRate * (h.cframe+1);
elseif h.cframe > h.nframes - 1
    h.vr{k}.currentTime = h.vr{k}.FrameRate * (h.cframe-1);
end
    

for j = 1:3
    fr = readFrame(h.vr{k});
    if size(fr,3) > 1
        fr = rgb2gray(fr);
    end
    frames(:,:,j) = fr;
end

sat    = min(254,max(1,(h.saturation(indROI))*255));
    
colormap('gray')    
    
% all ROIs besides pupil are down-sampled
if indROI > 3
    [nY nX nt]  = size(fr);
    nYc = floor(nY/sc)*sc;
    nXc = floor(nX/sc)*sc;
    fr  = squeeze(mean(reshape(frames(1:nYc,:),sc,nYc/sc,nX,nt),1));
    fr  = squeeze(mean(reshape(fr(:,1:nXc),nYc/sc,sc,nXc/sc,nt),2));
    fr     = single(frames(h.rY{indROI}, h.rX{indROI},:));
else
    fr = my_conv2(frames, [1 1 1], [1 2 3]);
    fr = fr(:,:,2);
end
  
if indROI < 3
    iroi = max(1,floor(h.locROI{indROI} * h.sc));
else
    iroi = h.locROI{indROI};
end

fr = fr(iroi(2)-1 + [1:iroi(4)], iroi(1)-1 + [1:iroi(3)], :);
    
% pupil and eye area contours
%imagesc(fr, [0 255-sat]);
if indROI < 3
    fr = fr - min(fr(:));
    fr = fr / max(fr(:)) * 255;
    imagesc(fr, [0 255-sat]);
    if indROI == 1
        r.fr     = fr;
        r.sats   = sat;
        r.thres  = h.thres;
        tpt      = 1;
        params    = FindGaussianContour(r,tpt);
        
        if params.isgood
            hold all;
            plot(params.xy(:,1),params.xy(:,2),'r.')
            plot(params.mu(1), params.mu(2), 'k*');
        end
    end
end

% show difference between frames for movement areas
if indROI > 2
    tdiff  = abs(fr(:,:,2)-fr(:,:,1));
    tdiff  = max(0, 5 - tdiff);
    sat    = min(4.99, max(0.01,(1-sat)*5));
    
    imagesc(tdiff,[0 sat]);
    %keyboard;
end
title(tstr{indROI},'fontsize',10);
    
axis off;
axis tight;
drawnow;
