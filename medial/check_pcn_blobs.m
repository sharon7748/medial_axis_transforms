
function [pcnSmall,pcnBig,pcncov] = check_pcn_blobs(pcnSmall,pcnBig,topTopFoldersDir,t,part1String,part2String,params,numParams)

% This function compare the thresholded data derived from PCN with the
% covariance projection of the DIC images
pcn1BB = cat(1,pcnSmall.BoundingBox);        
pcn1BB(:,[3 4]) = floor(pcn1BB(:,[3 4]) + pcn1BB(:,[1 2]));
pcn1BB(:,[1 2]) = ceil(pcn1BB(:,[1 2]));  
index = strfind(params.ThresholdRange,',');
MinimumThreshold = params.ThresholdRange(1:index-1);
MaximumThreshold = params.ThresholdRange(index+1:end);

[gfpImageSum, gfpImageF1] = load_sum_images(fullfile(topTopFoldersDir,[part1String, num2str(t,'%02d'), part2String]), 1, numParams);    
[td1ImageSum, td1ImageF1] = load_sum_images(fullfile(topTopFoldersDir,[part1String, num2str(t,'%02d'), part2String]), numParams(4), numParams);               

gfpImageF1Max = max(gfpImageF1,[],3);
gfpImageF1Max = gfpImageF1Max./max(gfpImageF1Max(:));
gfpImageF1Max = gfpImageF1Max > 0.05;
gfpImageF1Max = plug_holes(gfpImageF1Max,5);
gfpImageF1Max = bwareaopen(gfpImageF1Max,20);
gpfImageCC = bwconncomp(gfpImageF1Max);
gfpStats = regionprops(gpfImageCC,'centroid','Area','BoundingBox','PixelList','Image');             
gfpBB = cat(1,gfpStats.BoundingBox);        
gfpBB(:,[3 4]) = floor(gfpBB(:,[3 4]) + gfpBB(:,[1 2]));
gfpBB(:,[1 2]) = ceil(gfpBB(:,[1 2]));     
[gfpImageF1, zObs] = extract_clustersLOG(gfpImageF1,[], params, 1);
zObsBB = cat(1,zObs.stats.BoundingBox);        
zObsBB(:,[4 5 6]) = floor(zObsBB(:,[4 5 6]) + zObsBB(:,[1 2 3]));
zObsBB(:,[1 2 3]) = ceil(zObsBB(:,[1 2 3]));        
minSlice = min(zObsBB(:,3));
maxSlice = max(zObsBB(:,6));

td1ImageF1Q = td1ImageF1(:,:,minSlice:maxSlice); 
[covImage2N, covImageBW2N,~,thres] = get_std_thres(td1ImageF1,100,1,2,params);     
covImage2N = covImage2N./max(covImage2N(:));
acThreshold = cellProfilerThreshold(params.Threshold,0,MinimumThreshold,MaximumThreshold,params.ThresholdCorrection,max(covImage2N,[],3),'LoG');        
covImage2NMax = max(covImage2N,[],3) > 0.8*acThreshold;       
covImage2NMax = plug_holes(covImage2NMax,5);
covImage2NMax = bwareaopen(covImage2NMax,20);
covImage2NMax = bwmorph(covImage2NMax,'bridge',2);
covImage2NMax = bwareaopen(covImage2NMax,200);
covImage2NMaxMatch = bwareaopen(covImage2NMax,100);
covImageCC = bwconncomp(covImage2NMaxMatch);

covStats = regionprops(covImageCC,'centroid','Area','BoundingBox','PixelList','Image');        
covBB = cat(1,covStats.BoundingBox);        
covBB(:,[3 4]) = floor(covBB(:,[3 4]) + covBB(:,[1 2]));
covBB(:,[1 2]) = ceil(covBB(:,[1 2])); 

toAdd = [];
for a = 1:length(gfpStats)
    inXY = find_overlapBB(covBB,gfpBB(a,:));            
    anyIn = find(inXY == 1);      
    if(isempty(anyIn) == 0)
        aLength = zeros(length(anyIn),1);
        for k = 1:length(anyIn)
            anyIntersect = intersect(gfpStats(a).PixelList,covStats(anyIn(k)).PixelList,'rows');
            aLength(k) = length(anyIntersect);
        end
        anyIn = anyIn(aLength > 0);
    end
    if(isempty(anyIn))
       toAdd = [toAdd a];
    end
end
if(isempty(toAdd) == 0)
    numCovStats = length(covStats);
    for a = 1:length(toAdd)
        numCovStats = numCovStats + 1;
        covStats(numCovStats) = gfpStats(toAdd(a));
        covBB(numCovStats,:) = gfpBB(toAdd(a),:);
    end
end        

zeroMat = zeros(size(pcnSmall,1),1);
zeroMatC = num2cell(zeroMat);     
for m = 1:size(pcnSmall,1)
   pcncov(m).covAmt = [];
end
[pcncov.numCov] = deal(zeroMatC{:});

toAdd = [];
toRemove = zeros(length(covStats),1);

for a = 1:length(covStats)
    inXY = find_overlapBB(pcn1BB,covBB(a,:));
    anyIn = find(inXY == 1);
    if(isempty(anyIn) == 0)
        aLength = zeros(length(anyIn),1);
        for k = 1:length(anyIn)
            anyIntersect = intersect(covStats(a).PixelList,pcnSmall(anyIn(k)).PixelList,'rows');
            aLength(k) = length(anyIntersect);
        end
        anyIn = anyIn(aLength > 0);       
        aLength = aLength(aLength > 0);                       
        for k = 1:length(anyIn)
            pcncov(anyIn(k)).covAmt = [pcncov(anyIn(k)).covAmt aLength(k)/length(pcnSmall(anyIn(k)).PixelList)];    
            pcncov(anyIn(k)).numCov = pcncov(anyIn(k)).numCov + 1;                       
        end                
    end 
    if(isempty(anyIn))
       toAdd = [toAdd a];
    else
       toRemove(anyIn) = 1;
    end
end

%remove and add 
pcnSmallT = pcnSmall(toRemove == 1);
if(isempty(toAdd) == 0)
    numPcn = length(pcnSmallT);
    for a = 1:length(toAdd)
        numPcn = numPcn + 1;
        pcnSmallT(numPcn) = covStats(toAdd(a));
    end
end        

[pcnSmall,pcnBig] = checkBBoverlap(pcnSmallT,pcnBig);
  

