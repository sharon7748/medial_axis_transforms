function [pSkelMatch, pOrigMatch] = match_to_get_orig_boundary(pSkel,pOrig)

% just match between two groups using boundingboxes 
% check for overlapping pixels
% such that we get the original shape
% are hte skels the same siz

%pSkelMatch
%    matchPcn = matching pcn3Stats number for each pcnSkelStats
%    boundary = original boundary before skeletonization
%    numPcn = number of pcn3Stats that match the current pcnSkelStats 	
%    numOrigPcn = original numPcn 

pSkelBB = cat(1,pSkel.BoundingBox);        
pSkelBB(:,[3 4]) = floor(pSkelBB(:,[3 4]) + pSkelBB(:,[1 2]));
pSkelBB(:,[1 2]) = ceil(pSkelBB(:,[1 2]));  

pOrigBB = cat(1,pOrig.BoundingBox);        
pOrigBB(:,[3 4]) = floor(pOrigBB(:,[3 4]) + pOrigBB(:,[1 2]));
pOrigBB(:,[1 2]) = ceil(pOrigBB(:,[1 2]));

zeroMat = zeros(size(pSkel,1),1);
zeroMatC = num2cell(zeroMat);     
queueC = cell(size(pSkel,1),1);  
for n = 1:size(pSkel,1)
    pSkelMatch(n).matchPcn = [];
end
[pSkelMatch.boundary] = deal(queueC{:});
[pSkelMatch.numPcn] = deal(zeroMatC{:});         
[pSkelMatch.numOrigPcn] = deal(zeroMatC{:});         

%zeroMat = zeros(size(pOrig,1),1);
%zeroMatC = num2cell(zeroMat);     
%queueC = cell(size(pOrig,1),1);  
%[pOrigMatch.matchPcn] = deal(queueC{:});
%[pOrigMatch.numPcn] = deal(zeroMatC{:});       

for a = 1:length(pSkel)
    inXY = find_overlapBB(pOrigBB,pSkelBB(a,:));            
    anyIn = find(inXY == 1);        
    if(isempty(anyIn) == 0)
        aLength = zeros(length(anyIn),1);
        for k = 1:length(anyIn)
            anyIntersect = intersect(pSkel(a).PixelList,pOrig(anyIn(k)).PixelList,'rows');
            aLength(k) = length(anyIntersect);
        end
        anyIn = anyIn(aLength > 0);
        aLength = aLength(aLength > 0);               
        pSkelMatch(a).matchPcn = [pSkelMatch(a).matchPcn anyIn'];                
        pSkelMatch(a).numPcn = pSkelMatch(a).numPcn + length(anyIn);
        if(length(anyIn) == 1)
            [boundy,~,N] = bwboundaries(pOrig(anyIn).Image); 
            % adjust the differences in BoundingBoxes 
            if(N == 1)
                diffBound = pSkel(a).BoundingBox([2 1]) - pOrig(anyIn).BoundingBox([2 1]);
                pSkelMatch(a).boundary = bsxfun(@minus,boundy{1},floor(diffBound));            
%                pSkelMatch(a).numOrigPcn = pOrig(anyIn).numPcn;
              %  pause                 
            else
                disp('more than one boundy')
                pause 
            end             
        end               
      %  for k = 1:length(anyIn)
      %      pOrigMatch(anyIn(k)).matchPcn = [pOrigMatch(anyIn(k)).matchPcn a];
      %      pOrigMatch(anyIn(k)).numPcn = pOrigMatch(anyIn(k)).numPcn + 1;                       
      %  end                
    end        
end