% Motion segmentation with Robust Shape Interaction Matrix Method with JBLD

clear; close all
addpath(genpath('../3rdParty'));
addpath(genpath('../matlab'));
dataPath = '~/research/data/Hopkins155';

file = listFolder(dataPath);
ii = 0;
ii2 = 0;
ii3 = 0;
tic
for i = 1:length(file)
% for i = 76+3
        filePath = file{i};
        f = dir(fullfile(dataPath, filePath));
        foundValidData = false;
        for j = 1:length(f)
            if( ~isempty(strfind(f(j).name,'_truth.mat')) )
                ind = j;
                foundValidData = true;
                load(fullfile(dataPath, filePath, f(ind).name));
                if(max(s)==5)
                    foundValidData = false;
                end
                break;
            end
        end
        
        if(foundValidData)
            
            [s, ind] = sort(s); x = x(:, ind, :); y = y(:, ind, :);

            theta = pi / 4;
            T = [100; 50];
            y3 = permute(y, [1 3 2]);
            x3 = permute(x, [1 3 2]); x2 = x3;
            N = size(y3, 3);
            F = size(y3, 2);
            D = 3 * F;
            
            rng(0);
            ind = (rand(1, N) > 0.5);
            camID = ones(N, 1);
            for k = 1:N
                if ind(k) == true
                    y3(1:2, :, k) = rotation(y3(1:2, :, k), theta);
                    y3(1:2, :, k) = bsxfun(@plus, y3(1:2, :, k), T);
                    x3(:, :, k) = K \ squeeze(y3(:, :, k));
                    camID(k) = 2;
                end
            end
            [camID, idx] = sort(camID); x3 = x3(:, :, idx); s = s(idx);
            X = reshape(x3, D, N);
%             v3 = diff(x3, 1, 2); X = reshape(v3, 3*(F-1), N);
            
%             [missrate, grp, bestRank, minNcutValue,W, index] = RSIM(X, s);
%             [missrate, grp, bestRank, minNcutValue,W, index] = RSIM_JBLD(X, s, 4, 1);
%             [missrate, grp, bestRank, minNcutValue,W] = RSIM_JBLD2(X, s, 4, 1);
%             [missrate, grp, bestRank, minNcutValue,W, index] = RSIM_JBLD3(X, s, 4, 1, camID);
%             [missrate, grp, bestRank, minNcutValue,W] = RSIM_JBLD4(X, s, 4, 1, camID);
            [missrate, grp, index] = RSIM_View_JBLD_Obj(X, s, 4, 1, camID);
%             [missrate, grp, bestRank, minNcutValue,W, index] = RSIM_JBLD_oneshot(X, s, 4, 1, camID);
%             [missrate, grp, bestRank,W, index] = imprvRSIM_JBLD2(X, s, 4, 1, camID);

            nCluster = size(grp, 2);
            label = grp * (1:nCluster)';
            gt = index(s)';
            m1 = nnz(label(camID==1)~=gt(camID==1));
            m2 = nnz(label(camID==2)~=gt(camID==2));
            tc = nnz(label~=gt);
            
            ii = ii+1;
            Missrate(ii) = missrate;
            M1(ii) = m1;
            M2(ii) = m2;
            TC(ii) = tc;
%             disp([filePath ': ' num2str(100*Missrate(ii)) '%, dim:' num2str(bestRank) ', nMotions: ' num2str(max(s)) ', seq: ' num2str(ii)]);
            disp([filePath ': ' num2str(100*Missrate(ii)) '%, c1: ' ...
                num2str(M1(ii)) ', c2: ' num2str(M2(ii)) ', total error: ' num2str(TC(ii)) ', nMotions: ' num2str(max(s)) ', seq: ' num2str(ii)]);
            if(max(s)==2)
                ii2 = ii2+1;
                Missrate2(ii2) = Missrate(ii);
            else
                ii3 = ii3+1;
                Missrate3(ii3) = Missrate(ii);
            end
        end
%     end
end
time = toc;
avgtime = time/ii

avgtol = mean(Missrate);
medtol = median(Missrate);
avgtwo = mean(Missrate2);
medtwo = median(Missrate2);
avgthree = mean(Missrate3);
medthree = median(Missrate3);
sumC1 = sum(M1);
sumC2 = sum(M2);
sumTC = sum(TC);

disp('Results on Hopkins155')
disp(['Mean of all: ' num2str(100*avgtol) '%' ', median of all: ' num2str(100*medtol) '%;']);
disp(['Mean of two: ' num2str(100*avgtwo) '%' ', median of two: ' num2str(100*medtwo) '%;']);
disp(['Mean of three: ' num2str(100*avgthree) '%' ', median of three: ' num2str(100*medthree) '%;']);
disp(['error # of cam1: ' num2str(sumC1) ', error # of cam2: ' num2str(sumC2) ', total error #: ' num2str(sumTC) '.']);