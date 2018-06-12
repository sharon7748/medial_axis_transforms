function in = find_overlapBB(boxesBB,bbBox,do3D)

    if(exist('do3D','var') == 0)
        do3D = 1; 
    end
    
    if(length(bbBox) == 6)
        condition1x = boxesBB(:,1) >= bbBox(1) & boxesBB(:,1) <= bbBox(4);
        condition2x = boxesBB(:,1) <= bbBox(1) & boxesBB(:,4) >= bbBox(1);
        condition3x = boxesBB(:,1) <= bbBox(4) & boxesBB(:,4) >= bbBox(4);
        condition4x = boxesBB(:,4) >= bbBox(1) & boxesBB(:,4) <= bbBox(4);
        inX = condition1x|condition2x|condition3x|condition4x;
    
        condition1y = boxesBB(:,2) >= bbBox(2) & boxesBB(:,2) <= bbBox(5);
        condition2y = boxesBB(:,2) <= bbBox(2) & boxesBB(:,5) >= bbBox(2);
        condition3y = boxesBB(:,2) <= bbBox(5) & boxesBB(:,5) >= bbBox(5);
        condition4y = boxesBB(:,5) >= bbBox(2) & boxesBB(:,5) <= bbBox(5);
        inY = condition1y|condition2y|condition3y|condition4y;
    
        if(do3D == 1)
           condition1z = boxesBB(:,3) >= bbBox(3) & boxesBB(:,3) <= bbBox(6);
           condition2z = boxesBB(:,3) <= bbBox(3) & boxesBB(:,6) >= bbBox(3);
           condition3z = boxesBB(:,3) <= bbBox(6) & boxesBB(:,6) >= bbBox(6);
           condition4z = boxesBB(:,6) >= bbBox(3) & boxesBB(:,6) <= bbBox(6);
           inZ = condition1z|condition2z|condition3z|condition4z;
           in = inX&inY&inZ;       
        else
           in = inX&inY; 
        end
    else
        condition1x = boxesBB(:,1) >= bbBox(1) & boxesBB(:,1) <= bbBox(3);
        condition2x = boxesBB(:,1) <= bbBox(1) & boxesBB(:,3) >= bbBox(1);
        condition3x = boxesBB(:,1) <= bbBox(3) & boxesBB(:,3) >= bbBox(3);
        condition4x = boxesBB(:,3) >= bbBox(1) & boxesBB(:,3) <= bbBox(3);
        inX = condition1x|condition2x|condition3x|condition4x;
        condition1y = boxesBB(:,2) >= bbBox(2) & boxesBB(:,2) <= bbBox(4);
        condition2y = boxesBB(:,2) <= bbBox(2) & boxesBB(:,4) >= bbBox(2);
        condition3y = boxesBB(:,2) <= bbBox(4) & boxesBB(:,4) >= bbBox(4);
        condition4y = boxesBB(:,4) >= bbBox(2) & boxesBB(:,4) <= bbBox(4);
        inY = condition1y|condition2y|condition3y|condition4y;        
        in = inX&inY;         
    end