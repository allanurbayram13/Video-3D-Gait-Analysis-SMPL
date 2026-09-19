function generate_report(metrics, quality, MAT_FILE, output_file)
% Generate a text report of analysis

    if nargin < 4
        output_file = 'gait_analysis_report.txt';
    end

    fid = fopen(output_file, 'w');
    
    fprintf(fid, '========================================\n');
    fprintf(fid, 'GAIT ANALYSIS REPORT\n');
    fprintf(fid, '========================================\n\n');
    
    fprintf(fid, 'Input File: %s\n', MAT_FILE);
    fprintf(fid, 'Analysis Date: %s\n', datetime('now'));
    fprintf(fid, 'Data Quality Score: %.0f%%\n\n', quality.score);
    
    fprintf(fid, '--- METRICS SUMMARY ---\n');
    fprintf(fid, 'Cadence:         %.1f steps/min\n', metrics.cadence);
    fprintf(fid, 'Stride Length:   %.3f m\n', metrics.stride_length);
    fprintf(fid, 'Walking Speed:   %.3f m/s\n', metrics.walking_speed);
    fprintf(fid, 'Step Width:      %.3f m\n', metrics.step_width);
    fprintf(fid, 'Stance Phase:    %.1f%%\n', metrics.stance_pct);
    fprintf(fid, 'Swing Phase:     %.1f%%\n', metrics.swing_pct);
    fprintf(fid, 'Symmetry Index:  %.1f%%\n\n', metrics.symmetry_index);
    
    if ~isempty(quality.warnings)
        fprintf(fid, '--- QUALITY WARNINGS ---\n');
        for i = 1:length(quality.warnings)
            fprintf(fid, '• %s\n', quality.warnings{i});
        end
    end
    
    fclose(fid);
    fprintf('[REPORT] Saved to: %s\n', output_file);
end