function [pcn1Stats,pcn2Stats] = checkBBoverlap(pcn1Stats,pcn2Stats) 

% just match between two groups using boundingboxes 
% do we want to check for overlapping pixels? \
pcn1BB = cat(1,pcn1Stats.BoundingBox);        
pcn1BB(:,[3 4]) = floor(pcn1BB(:,[3 4]) + pcn1BB(:,[1 2]));
pcn1BB(:,[1 2]) = ceil(pcn1BB(:,[1 2]));  

pcn2BB = cat(1,pcn2Stats.BoundingBox);        
pcn2BB(:,[3 4]) = floor(pcn2BB(:,[3 4]) + pcn2BB(:,[1 2]));
pcn2BB(:,[1 2]) = ceil(pcn2BB(:,[1 2]));

zeroMat = zeros(size(pcn1Stats,1),1);
zeroMatC = num2cell(zeroMat);     
queueC = cell(size(pcn1Stats,1),1);     
[pcn1Stats.matchPcn] = deal(queueC{:});
[pcn1Stats.lengthPcn] = deal(queueC{:});         
[pcn1Stats.numPcn] = deal(zeroMatC{:});

zeroMat = zeros(size(pcn2Stats,1),1);
zeroMatC = num2cell(zeroMat);     
queueC = cell(size(pcn2Stats,1),1);  
[pcn2Stats.matchPcn] = deal(queueC{:});
[pcn2Stats.lengthPcn] = deal(queueC{:});         
[pcn2Stats.numPcn] = deal(zeroMatC{:});         

for a = 1:length(pcn1Stats)
    inXY = find_overlapBB(pcn2BB,pcn1BB(a,:));            
    anyIn = find(inXY == 1);        
    if(isempty(anyIn) == 0)
        aLength = zeros(length(anyIn),1);
        for k = 1:length(anyIn)
            anyIntersect = intersect(pcn1Stats(a).PixelList,pcn2Stats(anyIn(k)).PixelList,'rows');
            aLength(k) = length(anyIntersect);
        end
        anyIn = anyIn(aLength > 0);
        aLength = aLength(aLength > 0);               
        pcn1Stats(a).matchPcn = [pcn1Stats(a).matchPcn anyIn'];                
        pcn1Stats(a).lengthPcn = [pcn1Stats(a).lengthPcn (aLength/pcn1Stats(a).Area)'];  
        pcn1Stats(a).numPcn = pcn1Stats(a).numPcn + length(anyIn);
        for k = 1:length(anyIn)
            pcn2Stats(anyIn(k)).matchPcn = [pcn2Stats(anyIn(k)).matchPcn a];
            pcn2Stats(anyIn(k)).lengthPcn = [pcn2Stats(anyIn(k)).lengthPcn aLength(k)];    
            pcn2Stats(anyIn(k)).numPcn = pcn2Stats(anyIn(k)).numPcn + 1;                       
        end                
    end        
end