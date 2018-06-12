function [angleSe] = best_pcn_angle(td1Image,imgCheck,modalityType,tol,maxIt,scale)
%BEST_PCN_ANGLE Find the best angle for the DIC image preconditioning 
%   Detailed explanation goes here
    
    angleVec = [0 45 90 125 135 180 225 270 315];
    valuesMatch = zeros(numel(angleVec),1);
    for angleV = 1:length(angleVec)
        angle = angleVec(angleV); % 230;
        td1ImageT = reshape(pcnd(255*td1Image/max(td1Image(:)),modalityType,angle,0.01,0.5,tol,maxIt,scale),size(td1Image,2),size(td1Image,1));   
        valuesMatch(angleV) = sum(td1ImageT(imgCheck == 0));
    end

    [~, mv] = min(valuesMatch);
    angleSe = angleVec(mv);

    angleVecDiff1 = [-25 -15 -7 0 7 15 25];
    valuesMatch = zeros(numel(angleVecDiff1),1);
    for angleV = 1:length(angleVecDiff1)
        angle = angleVecDiff1(angleV) + angleSe;
        td1ImageT = reshape(pcnd(255*td1Image/max(td1Image(:)),modalityType,angle,0.01,0.5,tol,maxIt,scale),size(td1Image,2),size(td1Image,1));   
        valuesMatch(angleV,1) = sum(td1ImageT(imgCheck == 0));    
    end    
    
    [~, mv] = min(valuesMatch);
    angleSe = angleVecDiff1(mv) + angleSe;        
        
    angleVecDiff2 = [-5 -3 0 3 5];
    valuesMatchT2 = zeros(numel(angleVecDiff2),3);
    for angleV = 1:length(angleVecDiff2)
        angle = angleVecDiff2(angleV) + angleSe;
        td1ImageT = reshape(pcnd(255*td1Image/max(td1Image(:)),modalityType,angle,0.01,0.5,tol,maxIt,scale),size(td1Image,2),size(td1Image,1));           
        valuesMatchT2(angleV,1) = sum(td1ImageT(imgCheck == 0));           
    end    
    
   [~, mv] = min(valuesMatchT2(:,3));
   angleSe = angleVecDiff2(mv) + angleSe;           
end

