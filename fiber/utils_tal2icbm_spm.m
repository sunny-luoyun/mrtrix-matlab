function outpoints = utils_tal2icbm_spm(inpoints)
    dimdim = find(size(inpoints) == 3);
    if isempty(dimdim)
        error('input must be a N by 3 or 3 by N matrix')
    end
    if dimdim == [1 2]
        disp('input is an ambiguous 3 by 3 matrix')
        disp('assuming coordinates are row vectors')
        dimdim = 2;
    end
    if dimdim == 2
        inpoints = inpoints';
    end
    icbm_spm = [0.9254 0.0024 -0.0118 -1.0207
                -0.0048 0.9316 -0.0871 -1.7667
                 0.0152 0.0883  0.8924  4.0926
                 0.0000 0.0000  0.0000  1.0000];
    icbm_spm = inv(icbm_spm);
    inpoints = [inpoints; ones(1, size(inpoints, 2))];
    inpoints = icbm_spm * inpoints;
    outpoints = inpoints(1:3, :);
    if dimdim == 2
        outpoints = outpoints';
    end
end
