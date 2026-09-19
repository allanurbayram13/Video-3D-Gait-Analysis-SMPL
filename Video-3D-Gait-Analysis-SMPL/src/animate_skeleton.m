function animate_skeleton(joints, fps)
% ANIMATE_SKELETON  3D stick-figure animation from Body25 joint positions
%
%   animate_skeleton(joints, fps)
%
%   Body25 bone connections (MATLAB 1-based indices):
%     Spine:  1-2 (Nose-Neck), 2-9 (Neck-MidHip)
%     R arm:  2-3, 3-4, 4-5
%     L arm:  2-6, 6-7, 7-8
%     R leg:  9-10, 10-11, 11-12, 12-23, 12-25
%     L leg:  9-13, 13-14, 14-15, 15-20, 15-22

    % ── Bone definitions [joint_A, joint_B] ───────────────────────────────
    bones = [
        1  2;   % Nose - Neck
        2  9;   % Neck - MidHip
        2  3;   % Neck - R_Shoulder
        3  4;   % R_Shoulder - R_Elbow
        4  5;   % R_Elbow - R_Wrist
        2  6;   % Neck - L_Shoulder
        6  7;   % L_Shoulder - L_Elbow
        7  8;   % L_Elbow - L_Wrist
        9 10;   % MidHip - R_Hip
       10 11;   % R_Hip - R_Knee
       11 12;   % R_Knee - R_Ankle
       12 23;   % R_Ankle - R_BigToe
       12 25;   % R_Ankle - R_Heel
        9 13;   % MidHip - L_Hip
       13 14;   % L_Hip - L_Knee
       14 15;   % L_Knee - L_Ankle
       15 20;   % L_Ankle - L_BigToe
       15 22;   % L_Ankle - L_Heel
    ];

    C_R    = [0.00 0.45 0.70];   % blue  = right limbs
    C_L    = [0.85 0.33 0.10];   % orange = left limbs
    C_BODY = [0.20 0.20 0.20];   % dark  = spine
    % Assign colour per bone
    bone_colors = [
        C_BODY; C_BODY;               % spine
        C_R; C_R; C_R;                % right arm
        C_L; C_L; C_L;                % left arm
        C_R; C_R; C_R; C_R; C_R;     % right leg
        C_L; C_L; C_L; C_L; C_L;     % left leg
    ];

    N      = size(joints, 1);
    step   = max(1, round(fps/20));
    all_x = squeeze(joints(:,:,1));
    all_y = squeeze(joints(:,:,2));
    all_z = squeeze(joints(:,:,3));
    pad   = 0.15;
    xl = [min(all_x(:))-pad, max(all_x(:))+pad];
    yl = [min(all_y(:))-pad, max(all_y(:))+pad];
    zl = [min(all_z(:))-pad, max(all_z(:))+pad];

    fig = figure('Name','Skeleton Animation','Color','k', ...
                 'Position',[200 100 800 600]);
    ax  = axes('Parent',fig,'Color','k','XColor','w','YColor','w','ZColor','w');
    hold(ax,'on'); grid(ax,'on'); box(ax,'on');
    xlabel(ax,'X (m)','Color','w'); 
    ylabel(ax,'Y (m)','Color','w');
    zlabel(ax,'Z (m)','Color','w');
    title(ax,'3D Gait Reconstruction — SMPL / Body25','Color','w','FontSize',13);
    xlim(ax,xl); ylim(ax,yl); zlim(ax,zl);
    view(ax, 35, 20);

    n_bones  = size(bones,1);
    h_bones  = gobjects(n_bones,1);
    for b = 1:n_bones
        h_bones(b) = plot3(ax, 0,0,0, '-', ...
            'Color', bone_colors(b,:), 'LineWidth', 2.5);
    end
    % Joint scatter
    h_joints = scatter3(ax, 0,0,0, 30, 'w', 'filled');

    % Trajectory trace (pelvis)
    h_trace  = plot3(ax, nan,nan,nan, '-', 'Color',[0.5 1 0.5], 'LineWidth',1.2);

    % Frame label
    h_txt = text(ax, xl(1), yl(2), zl(2), '', 'Color','w', 'FontSize',10);

    pelvis_trace_x = nan(1,N);
    pelvis_trace_y = nan(1,N);
    pelvis_trace_z = nan(1,N);

    for f = 1:step:N
        if ~isvalid(fig), break; end

        pts = squeeze(joints(f,:,:));   % (25 x 3)
        X   = pts(:,1);
        Y   = pts(:,2);
        Z   = pts(:,3);

        % Update bones
        for b = 1:n_bones
            j1 = bones(b,1);
            j2 = bones(b,2);
            set(h_bones(b), ...
                'XData', [X(j1) X(j2)], ...
                'YData', [Y(j1) Y(j2)], ...
                'ZData', [Z(j1) Z(j2)]);
        end

        % Update joints
        set(h_joints, 'XData',X, 'YData',Y, 'ZData',Z);

        % Update pelvis trajectory trace
        pelvis_trace_x(f) = pts(9,1);
        pelvis_trace_y(f) = pts(9,2);
        pelvis_trace_z(f) = pts(9,3);
        set(h_trace, 'XData',pelvis_trace_x, ...
                     'YData',pelvis_trace_y, ...
                     'ZData',pelvis_trace_z);

        set(h_txt, 'String', sprintf('Frame %d / %d  (%.2f s)', ...
                   f, N, f/fps));

        drawnow limitrate;
        pause(step/fps * 0.9);
    end

    fprintf('[7] Animation complete (%d frames shown)\n', N);
end