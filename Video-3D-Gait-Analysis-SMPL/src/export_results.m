function export_results(metrics, normalized, events, N, fps, filename)
% Export analysis results to CSV and PDF

    % ── CSV Export ─────────────────────────────────────────────────────
    csv_file = strrep(filename, '.mat', '_results.csv');
    
    headers = {'Parameter', 'Value', 'Unit', 'Normal Range', 'Status'};
    
    rows = {
        'Cadence',         metrics.cadence,          'steps/min', '100-130', '';
        'Stride Length',   metrics.stride_length,    'm',         '1.30-1.60', '';
        'Walking Speed',   metrics.walking_speed,    'm/s',       '1.20-1.60', '';
        'Step Width',      metrics.step_width,       'm',         '0.06-0.12', '';
        'Stance Phase',    metrics.stance_pct,       '%',         '55-65', '';
        'Swing Phase',     metrics.swing_pct,        '%',         '35-45', '';
        'Symmetry Index',  metrics.symmetry_index,   '%',         '<10', '';
    };
    
    T = cell2table(rows, 'VariableNames', headers);
    writetable(T, csv_file);
    fprintf('[EXPORT] Results saved to: %s\n', csv_file);
end