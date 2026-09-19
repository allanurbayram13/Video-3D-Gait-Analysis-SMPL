function plot_results(angles, normalized, events, metrics, fps, N)
% PLOT_RESULTS  Generate all gait analysis figures
%
%   Figure 1: Raw joint angle time series with event markers
%   Figure 2: Normalized gait cycle curves (mean ± std) with normative bands
%   Figure 3: Clinical metrics table with pass/fail flags
%   Figure 4: Left vs Right symmetry comparison bar chart

    t = (0:N-1) / fps;   % time axis in seconds

    % ── Winter (1991) normative data (approximate, mean ± 1 SD) ──────────
    % Knee flexion over gait cycle (0-100%): peaks ~60-70° in swing
    gc = 0:100;
    norm_knee_mean = 5  + 60  * sin(gc/100 * pi).^2 .* ...
                    (1 - 0.4*sin(gc/100*2*pi));
    norm_knee_std  = ones(1,101) * 8;

    % Hip (trunk-hip-knee angle): roughly 150-170° range
    norm_hip_mean  = 160 + 8 * sin(gc/100 * 2*pi + 0.5);
    norm_hip_std   = ones(1,101) * 7;

    % Ankle (knee-ankle-toe angle): roughly 90-115° range
    norm_ankle_mean = 100 + 10 * sin(gc/100 * 2*pi);
    norm_ankle_std  = ones(1,101) * 8;

    % ── Colour scheme ─────────────────────────────────────────────────────
    C_R   = [0.00 0.45 0.70];    % blue   = right
    C_L   = [0.85 0.33 0.10];    % orange = left
    C_N   = [0.75 0.75 0.75];    % gray   = normative band
    C_HS  = [0.20 0.63 0.17];    % green  = heel strike
    C_TO  = [0.89 0.10 0.11];    % red    = toe-off

    % =========================================================
    % FIGURE 1 — Raw joint angle time series
    % =========================================================
    figure('Name','Fig 1 — Joint Angle Time Series', ...
           'Position',[50 50 1200 700], 'Color','w');

    angle_names = {'Knee Flexion','Hip Angle','Ankle Angle'};
    R_fields    = {'knee_R','hip_R','ankle_R'};
    L_fields    = {'knee_L','hip_L','ankle_L'};

    for k = 1:3
        subplot(3,1,k);
        hold on; box on;

        sig_R = angles.(R_fields{k});
        sig_L = angles.(L_fields{k});

        plot(t, sig_R, '-', 'Color', C_R, 'LineWidth', 1.4, 'DisplayName', 'Right');
        plot(t, sig_L, '-', 'Color', C_L, 'LineWidth', 1.4, 'DisplayName', 'Left');

        % Mark heel strikes
        yl = ylim;
        for hs = events.heel_strike_R'
            xline(hs/fps, '--', 'Color', C_HS, 'Alpha', 0.6, 'LineWidth', 0.8);
        end
        for hs = events.heel_strike_L'
            xline(hs/fps, ':', 'Color', C_HS, 'Alpha', 0.6, 'LineWidth', 0.8);
        end

        ylabel('Angle (°)', 'FontSize', 11);
        title(angle_names{k}, 'FontSize', 12, 'FontWeight', 'bold');
        if k == 1
            legend('Right','Left','Location','northeast','FontSize',9);
        end
        if k == 3
            xlabel('Time (s)', 'FontSize', 11);
        end
        grid on;
    end
    sgtitle('Joint Angle Time Series — Body25 / SMPL', ...
            'FontSize', 14, 'FontWeight', 'bold');

    % =========================================================
    % FIGURE 2 — Normalized gait cycle with normative bands
    % =========================================================
    figure('Name','Fig 2 — Gait Cycle (Normalized)', ...
           'Position',[80 80 1200 700], 'Color','w');

    gc_x = 0:100;

    plot_pairs = {
        'Knee Flexion',  'mean_knee_R',  'std_knee_R',  'mean_knee_L',  'std_knee_L',  norm_knee_mean,  norm_knee_std;
        'Hip Angle',     'mean_hip_R',   'std_hip_R',   'mean_hip_L',   'std_hip_L',   norm_hip_mean,   norm_hip_std;
        'Ankle Angle',   'mean_ankle_R', 'std_ankle_R', 'mean_ankle_L', 'std_ankle_L', norm_ankle_mean, norm_ankle_std;
    };

    for k = 1:3
        subplot(3,1,k);
        hold on; box on;

        label    = plot_pairs{k,1};
        mn_R     = normalized.(plot_pairs{k,2});
        sd_R     = normalized.(plot_pairs{k,3});
        mn_L     = normalized.(plot_pairs{k,4});
        sd_L     = normalized.(plot_pairs{k,5});
        n_mean   = plot_pairs{k,6};
        n_std    = plot_pairs{k,7};

        % Normative band (gray)
        fill([gc_x, fliplr(gc_x)], ...
             [n_mean+n_std, fliplr(n_mean-n_std)], ...
             C_N, 'EdgeColor','none', 'FaceAlpha',0.4, ...
             'DisplayName','Normative ±1SD');

        % Mean ± SD bands (shaded)
        fill([gc_x, fliplr(gc_x)], ...
             [mn_R+sd_R, fliplr(mn_R-sd_R)], ...
             C_R, 'EdgeColor','none', 'FaceAlpha',0.15);
        fill([gc_x, fliplr(gc_x)], ...
             [mn_L+sd_L, fliplr(mn_L-sd_L)], ...
             C_L, 'EdgeColor','none', 'FaceAlpha',0.15);

        % Mean curves
        plot(gc_x, mn_R, '-',  'Color', C_R, 'LineWidth', 2.2, 'DisplayName','Right mean');
        plot(gc_x, mn_L, '--', 'Color', C_L, 'LineWidth', 2.2, 'DisplayName','Left mean');

        % Stance / swing divider (~60%)
        xline(60, ':', 'Color',[0.4 0.4 0.4], 'LineWidth',1.2);
        text(30, max(ylim)*0.95, 'Stance', 'HorizontalAlignment','center', ...
             'FontSize',9, 'Color',[0.4 0.4 0.4]);
        text(80, max(ylim)*0.95, 'Swing', 'HorizontalAlignment','center', ...
             'FontSize',9, 'Color',[0.4 0.4 0.4]);

        ylabel('Angle (°)', 'FontSize', 11);
        title(label, 'FontSize', 12, 'FontWeight','bold');
        if k == 1
            legend('Location','northeast','FontSize',9);
        end
        if k == 3
            xlabel('Gait Cycle (%)', 'FontSize', 11);
        end
        xlim([0 100]); grid on;
    end
    sgtitle('Normalized Gait Cycle — Mean ± SD  vs  Winter''s Normative Data', ...
            'FontSize',14, 'FontWeight','bold');

    % =========================================================
    % FIGURE 3 — Clinical metrics summary table
    % =========================================================
    figure('Name','Fig 3 — Clinical Metrics', ...
           'Position',[110 110 700 500], 'Color','w');
    axis off;

    % Define table: {Label, Value, Unit, NormalRange, Pass?}
    rows = {
        'Cadence',         metrics.cadence,          'steps/min', [100 130];
        'Stride Length',   metrics.stride_length,    'm',         [1.30 1.60];
        'Walking Speed',   metrics.walking_speed,    'm/s',       [1.20 1.60];
        'Step Width',      metrics.step_width,       'm',         [0.06 0.12];
        'Stance Phase',    metrics.stance_pct,       '%',         [55 65];
        'Swing Phase',     metrics.swing_pct,        '%',         [35 45];
        'Symmetry Index',  metrics.symmetry_index,   '%',         [0 10];
    };

    headers = {'Parameter','Value','Unit','Normal Range','Status'};
    col_x   = [0.02 0.32 0.52 0.62 0.85];
    row_h   = 0.11;
    y_start = 0.92;

    % Header row
    for c = 1:5
        text(col_x(c), y_start, headers{c}, ...
             'Units','normalized', 'FontSize',11, ...
             'FontWeight','bold', 'Color',[0.1 0.1 0.4]);
    end
    % Divider
    annotation('line',[0.05 0.95],[y_start-0.03 y_start-0.03], ...
               'Color',[0.3 0.3 0.3],'LineWidth',1.5);

    for r = 1:size(rows,1)
        label  = rows{r,1};
        val    = rows{r,2};
        unit   = rows{r,3};
        nr     = rows{r,4};
        y_pos  = y_start - r*row_h - 0.02;

        if isnan(val)
            val_str    = 'N/A';
            status_str = '—';
            clr        = [0.5 0.5 0.5];
        elseif val >= nr(1) && val <= nr(2)
            val_str    = sprintf('%.2f', val);
            status_str = '✓ Normal';
            clr        = [0.15 0.55 0.15];
        else
            val_str    = sprintf('%.2f', val);
            status_str = '✗ Atypical';
            clr        = [0.75 0.15 0.15];
        end
        nr_str = sprintf('[%.2f – %.2f]', nr(1), nr(2));

        text(col_x(1), y_pos, label,    'Units','normalized','FontSize',10);
        text(col_x(2), y_pos, val_str,  'Units','normalized','FontSize',10, 'FontWeight','bold');
        text(col_x(3), y_pos, unit,     'Units','normalized','FontSize',10, 'Color',[0.4 0.4 0.4]);
        text(col_x(4), y_pos, nr_str,   'Units','normalized','FontSize',10, 'Color',[0.4 0.4 0.4]);
        text(col_x(5), y_pos, status_str,'Units','normalized','FontSize',10, ...
             'FontWeight','bold','Color', clr);
    end

    title('Clinical Gait Metrics — vs Winter (1991) Normative Ranges', ...
          'FontSize',13,'FontWeight','bold');

    % =========================================================
    % FIGURE 4 — Left vs Right symmetry bars
    % =========================================================
    figure('Name','Fig 4 — L/R Symmetry', ...
           'Position',[140 140 700 420], 'Color','w');

    bar_labels = {'Stride Length (m)', 'Step Width (m)'};
    R_vals     = [metrics.stride_length_R, metrics.step_width];
    L_vals     = [metrics.stride_length_L, metrics.step_width];

    b = bar([R_vals; L_vals]', 'grouped');
    b(1).FaceColor = C_R;  b(1).DisplayName = 'Right';
    b(2).FaceColor = C_L;  b(2).DisplayName = 'Left';

    set(gca,'XTickLabel', bar_labels, 'FontSize',11, 'Box','off');
    ylabel('Value', 'FontSize',12);
    legend('Right','Left','Location','northwest','FontSize',11);
    title(sprintf('Left–Right Symmetry  (Symmetry Index = %.1f%%)', ...
                  metrics.symmetry_index), ...
          'FontSize',13,'FontWeight','bold');
    grid on; ylim([0 max([R_vals L_vals])*1.25]);

    fprintf('[6] Figures generated: time series, gait cycles, metrics table, symmetry\n');
end
