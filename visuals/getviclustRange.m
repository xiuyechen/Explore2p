% from Suite2p, modified for Explore2p

function [iclust1, V1] = getviclust(stat, Ly, Lx, vmap, ichosen)

iclust1 = zeros(Ly, Lx);
V1      = zeros(Ly, Lx);
% V2      = zeros(Ly, Lx);

if size(ichosen,1)>1
    range = ichosen';
else
    range = ichosen;
end

for j = range
    ipix    = stat(j).ipix;
    lambda   = stat(j).lambda;
    
%     if ichosen==j
%         inew = true(numel(ipix), 1);
%     else
        
            inew    = lambda(:)>(V1(ipix) + 1e-6);

%     end
    
    switch vmap
        case 'var'
            L0      = stat(j).lambda(inew);
        case 'unit'
            L0      = stat(j).lam(inew);    
    end

        V1(ipix(inew))      = L0;
        iclust1(ipix(inew)) = j;

end

% normalize
mV = mean(V1(V1>0));
V1 = V1/mV;
end
% 
% function [iclust1, iclust2, V1, V2] = getviclust(stat, Ly, Lx, vmap, ichosen)
% 
% iclust1 = zeros(Ly, Lx);
% iclust2 = zeros(Ly, Lx);
% V1      = zeros(Ly, Lx);
% V2      = zeros(Ly, Lx);
% 
% for j = 1:numel(stat)
%     ipix    = stat(j).ipix;
%     lambda   = stat(j).lambda;
%     
%     if ichosen==j
%         inew = true(numel(ipix), 1);
%     else
%         if stat(j).iscell
%             inew    = lambda(:)>(V1(ipix) + 1e-6);
%         else
%             inew    = lambda(:)>(V2(ipix) + 1e-6);
%         end
%     end
%     
%     switch vmap
%         case 'var'
%             L0      = stat(j).lambda(inew);
%         case 'unit'
%             L0      = stat(j).lam(inew);    
%     end
%     if stat(j).iscell
%         V1(ipix(inew))      = L0;
%         iclust1(ipix(inew)) = j;
%     else
%         V2(ipix(inew))      = L0;
%         iclust2(ipix(inew)) = j;
%     end
% end
% mV = mean([V1(V1>0); V2(V2>0)]);
% V1 = V1/mV;
% V2 = V2/mV;
% end