function plot_study_results(study)
% MATLAB dashboard; Octave can use tools/plot_outputs.py after the numeric run.
fig=figure('Color','w','Position',[60 60 1200 760]);
labels={'Fixed wheel rate','Fixed axle roll stiffness'};
fields={'Ay_capacity','front_roll_fraction'};
for panel=1:4
    subplot(2,2,panel); hold on; grid on;
    for s=1:numel(study.scenarios)
        scenario=study.scenarios(s);
        if panel==1
            y=[scenario.lap.lap_time_s];
            y=y-y(scenario.baseline_idx);
            ylabel('Lap time change [s]');
            title('Fixed-path screening: not transient agility');
        elseif panel==2
            y=[scenario.vehicle.(fields{1})];
            ylabel('Steady-state capacity [g]'); title('First axle or wheel-lift limit');
        elseif panel==3
            y=[scenario.vehicle.(fields{2})]*100;
            ylabel('Front roll stiffness fraction [%]'); title('Controlled roll-stiffness scenarios');
        else
            y=[scenario.skidpad.lap_time_s];
            ylabel('Skidpad single lap [s]'); title('Ideal steering; actual rack not evaluated');
        end
        plot(study.tracks_mm,y,'-o','DisplayName',labels{s},'LineWidth',1.5);
    end
    xlabel('Front track [mm]'); legend('Location','best');
end
print(fig,fullfile(study.output_dir,'track_width_dashboard.png'),'-dpng','-r160');
end
