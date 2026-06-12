function step1_resp(workPath, subList, algorithm, params)
    fbaSubDir = fullfile(workPath, 'fba', 'subjects');
    for i = 1:length(subList)
        sub = subList{i};
        subDir = fullfile(fbaSubDir, sub);
        if ~exist(fullfile(subDir, 'dwi.mif'), 'file')
            warning('跳过 %s: dwi.mif 不存在', sub);
            continue;
        end
        if strcmp(algorithm, 'dhollander')
            cmd = sprintf('dwi2response dhollander %s/dwi.mif %s/response_wm.txt %s/response_gm.txt %s/response_csf.txt -erode %d -fa %f -sfwm %f -gm %d -csf %d -force', ...
                subDir, subDir, subDir, subDir, ...
                params.erode, params.fa, params.sfwm, params.gm, params.csf);
        else
            cmd = sprintf('dwi2response tournier %s/dwi.mif %s/response_wm.txt -max_iters %d -sfwm %d -next_fiber %d -change %f -force', ...
                subDir, subDir, ...
                params.max_iters, params.sfwm, params.next_fiber, params.change);
        end
        system(cmd);
    end
end
