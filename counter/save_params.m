function paramFile = save_params(class, detail, workPath, params)
    ts = datetime('now', 'Format', 'yyyyMMdd_HHmmss');
    filename = sprintf('%s_%s.mat', detail, char(ts));
    filepath = fullfile(workPath, filename);

    data = struct();
    data.class = class;
    data.detail = detail;
    data.timestamp = datetime('now');
    data.params = params;

    save(filepath, '-struct', 'data');
    paramFile = filepath;
end
