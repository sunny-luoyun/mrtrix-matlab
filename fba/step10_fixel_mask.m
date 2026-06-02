function step10_fixel_mask(workPath, fmlsPeak)
    templateDir = fullfile(workPath, 'fba', 'template');
    cmd = sprintf('fod2fixel -mask %s/template_mask.mif -fmls_peak_value %f %s/wmfod_template.mif %s/fixel_mask -force', ...
        templateDir, fmlsPeak, templateDir, templateDir);
    system(cmd);
end
