% Quick script to plot the sample data
% Assumes synced_force_disp and target variables exist in the workspace already

% make plots pretty
set(groot,'defaultAxesTickLabelInterpreter','latex');
set(groot,'defaulttextinterpreter','latex');
set(groot,'defaultLegendInterpreter','latex');
set(groot,'defaultAxesFontSize',20);
set(groot,'defaultLineLineWidth',2);
set(groot,'defaultAxesBox','on')
set(groot,'defaultTextFontSize',16)

% load data
inst_data = get_inst_data(target{3});

%% plot
figure
hold on
scatter(inst_data.Time, inst_data.Force, 'filled', 'MarkerFaceAlpha', 0.5, 'MarkerEdgeAlpha', 0.5, "DisplayName", "Instron Data");
plot(synced_force_disp.Time,synced_force_disp.Force,"DisplayName","Synced Data");

legend("Location","southwest");

xlabel("Time [$$s$$]");
ylabel("Force [$$N$$]");

grid on
grid minor

title("Force vs. Time Comparison")

% Add a mini picture-in-picture plot
axes('Position',[.6 .6 .25 .25])
box on
hold on
scatter(inst_data.Time, inst_data.Force, 'filled', 'MarkerFaceAlpha', 0.5, 'MarkerEdgeAlpha', 0.5);
plot(synced_force_disp.Time, synced_force_disp.Force, '-x','MarkerSize',12);
xlim([2000 2010])

grid on
grid minor

figure
hold on
plot(inst_data.Displacement, inst_data.Force, "DisplayName", "Instron Data");
plot(synced_force_disp.("ΔL"),synced_force_disp.Force,"DisplayName","Synced Data");

legend("Location","best");

xlabel("Displacement [$$mm$$]");
ylabel("Force [$$N$$]");
grid on
grid minor

xlim([-.1, .5])

title("Force vs. Displacement Comparison")

