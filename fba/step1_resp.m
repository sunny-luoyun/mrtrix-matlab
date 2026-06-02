function step1_resp(workPath, startname, subList, algorithm, params)
    fbaSubDir = fullfile(workPath, 'fba', 'subjects');
    for i = 1:length(subList)
        sub = subList{i};
        subDir = fullfile(fbaSubDir, sub);
        mkdir(subDir);
        src = fullfile(workPath, startname, sub, 'dwi.mif');
        if ~exist(src, 'file')
            warning('跳过 %s: %s 不存在', sub, src);
            continue;
        end
        dst = fullfile(subDir, 'dwi.mif');
        if ~exist(dst, 'file')
            copyfile(src, dst);
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
