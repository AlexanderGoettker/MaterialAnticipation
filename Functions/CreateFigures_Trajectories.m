function [metrics] = CreateFiguresTrajetcories(metrics,sub)

close all
global resultpath
%Define plotting things
Colormap = [152 0 54; 113 112 110]./255;
Colormap_exp = [59 100 33; 200 50 53; 180 180 180]./255;
Shiftmap = [-0.2 0.2];
Labels = {'Consistent','Inconsistent','Masks'};
Consistent_First = find(metrics.Order == 1);
Inconsistent_First = find(metrics.Order == 2);
SubplotMat = [5 4 6];

%% Show the trajectory plots
for exp =1:3
    for mat =1:2

        sub.critical_frame*1000/30;

        TimeWindow = [1:2501];
        figure(1000+exp)
        hold on;
        x_tar = squeeze(metrics.HorVekTarAll(TimeWindow,exp,1,mat));
        y_tar = squeeze(metrics.VerVekTarAll(TimeWindow,exp,1,mat));
        x_eye = mean(squeeze(metrics.HorVekAll(TimeWindow,exp,:,mat)),2);
        y_eye = mean(squeeze(metrics.VerVekAll(TimeWindow,exp,:,mat)),2);
        if mat == 1
            plot(x_tar,y_tar,'--','Color',Colormap(mat,:))
        else
            plot(x_tar,y_tar,':','Color',Colormap(mat,:))
        end
        n = length(x_eye);
        colors = cbrewer('div','RdYlBu',n-1); colors(colors>1) = 1; colors(colors<0)=0;
        for i = 1:length(x_tar)-1
            plot(x_eye(i:i+1), y_eye(i:i+1), '--', ...
                'Color', colors(i,:), ...
                'LineWidth', 7);
        end
        colormap(colors)
        cb = colorbar;
        xlabel('Horizontal Position [dva]')
        ylabel('Vertical Position [dva]')
        cb.Label.String = 'Time in Video ';

        % Add isosynchrony lines
        Timepoints = [1 1000 1500 round((sub.critical_frame-1)*(1000/30)) 2500];
        for aa=1:length(Timepoints)
            plot([x_tar(Timepoints(aa)) x_eye(Timepoints(aa))], [y_tar(Timepoints(aa)) y_eye(Timepoints(aa))],'k-','Color',[0.5 0.5 0.5])
        end
        title(Labels{exp})
        %         TimeWindow = [1:2501];
        %         figure(10+exp)
        %         hold on;
        %            x_tar = squeeze(metrics.HorVekTarAll(TimeWindow,exp,1,mat));
        %         y_tar = squeeze(metrics.VerVekTarAll(TimeWindow,exp,1,mat));
        %         x_eye = mean(squeeze(metrics.HorVekAll(TimeWindow,exp,:,mat)),2);
        %         y_eye = mean(squeeze(metrics.VerVekAll(TimeWindow,exp,:,mat)),2);
        %         y_eye_std = 2*(std(squeeze(metrics.VerVekAll(TimeWindow,exp,:,mat))')/sqrt(size(metrics.BadTrialsSub,2)));
        %         shadedErrorBar(x_eye,y_eye,y_eye_std,'lineprops',{'-','Color',Colormap(mat,:)})
        %         plot(x_tar,y_tar,'--','Color',Colormap(mat,:))
        %         Timepoints = [1 1000 1500 round((sub.critical_frame-1)*(1000/30)) 2500];
        %         for aa=1:length(Timepoints)
        %             plot([x_tar(Timepoints(aa)) x_eye(Timepoints(aa))], [y_tar(Timepoints(aa)) y_eye(Timepoints(aa))],'k-','Color',[0 0 0])
        %         end




        %% Figures across time
        %         figure(11);
        %         subplot(1,3,exp)
        %         hold on;
        %         plot(median(squeeze(metrics.VerVek(:,exp,:,mat)),2),sub.Timing,'-','Color',Colormap(mat,:),'LineWidth',2)
        %         plot(median(squeeze(metrics.VerVek(:,exp,:,mat)),2)+(std(squeeze(metrics.VerVek(:,exp,:,mat))')'/sqrt(size(metrics.VerVek,3)))*2,sub.Timing,'--','Color',Colormap(mat,:),'LineWidth',0.5)
        %         plot(median(squeeze(metrics.VerVek(:,exp,:,mat)),2)-(std(squeeze(metrics.VerVek(:,exp,:,mat))')'/sqrt(size(metrics.VerVek,3)))*2,sub.Timing,'--','Color',Colormap(mat,:),'LineWidth',0.5)
        %         plot(squeeze(metrics.VerVekTar(:,exp,1,mat)),sub.Timing,':','Color',Colormap(mat,:),'LineWidth',1)
        %         set(gca,'YDir','reverse')
        %         ylim([-400 400])
        %         xlim([-8 4])
        %         plot([-8 4],[0 0],'k-')
        %         title(Labels{exp})
        %         ylabel('Time relative to Water Contact [ms]')
        %         xlabel('Vertical Eye Position [dva]')
        %
        %          figure(12);
        %         subplot(1,3,exp)
        %         hold on;
        %         plot(median(squeeze(metrics.HorVek(:,exp,:,mat)),2),sub.Timing,'-','Color',Colormap(mat,:),'LineWidth',2)
        %         plot(median(squeeze(metrics.HorVek(:,exp,:,mat)),2)+(std(squeeze(metrics.HorVek(:,exp,:,mat))')'/sqrt(size(metrics.VerVek,3)))*2,sub.Timing,'--','Color',Colormap(mat,:),'LineWidth',0.5)
        %         plot(median(squeeze(metrics.HorVek(:,exp,:,mat)),2)-(std(squeeze(metrics.HorVek(:,exp,:,mat))')'/sqrt(size(metrics.VerVek,3)))*2,sub.Timing,'--','Color',Colormap(mat,:),'LineWidth',0.5)
        %         plot(squeeze(metrics.HorVekTar(:,exp,1,mat)),sub.Timing,':','Color',Colormap(mat,:),'LineWidth',1)
        %         set(gca,'YDir','reverse')
        %         ylim([-400 400])
        %         xlim([-8 4])
        %         plot([-8 4],[0 0],'k-')
        %         title(Labels{exp})
        %         ylabel('Time relative to Water Contact [ms]')
        %         xlabel('Horizontal Eye Position [dva]')

        %% Figures across time

        figure(100000+exp);
        hold on;
        plot(sub.Timing,squeeze(metrics.VerVek(:,exp,:,mat)),'-','Color',Colormap(mat,:))
        if mat == 1
            plot(sub.Timing,squeeze(metrics.VerVekTar(:,exp,1,mat)),'--','Color',Colormap(mat,:),'LineWidth',1)
        else
            plot(sub.Timing,squeeze(metrics.VerVekTar(:,exp,1,mat)),':','Color',Colormap(mat,:),'LineWidth',1)
        end
        xlim([-400 400])
        ylim([-8 4])
        plot([0 0],[-8 4],'k-')
        title(Labels{exp})
        xlabel('Time relative to Water Contact [ms]')
        ylabel('Vertical Eye Position [dva]')



        %
        %         figure(10000+exp);
        %         hold on;
        %         shadedErrorBar(sub.Timing,mean(squeeze(metrics.VerVek(:,exp,:,mat)),2),2*(std(squeeze(metrics.VerVek(:,exp,:,mat))')/sqrt(size(metrics.BadTrialsSub,2))),'lineprops',{'-','Color',Colormap(mat,:)})
        %         plot(sub.Timing,mean(squeeze(metrics.VerVek(:,exp,:,mat)),2),'-','Color',Colormap(mat,:),'LineWidth',2)
        %         plot(sub.Timing,squeeze(metrics.VerVekTar(:,exp,1,mat)),'--','Color',Colormap(mat,:),'LineWidth',1)
        %         xlim([-400 400])
        %         ylim([-8 4])
        %         plot([0 0],[-8 4],'k-')
        %         title(Labels{exp})
        %         xlabel('Time relative to Water Contact [ms]')
        %         ylabel('Vertical Eye Position [dva]')
        %
        %         figure(100000+exp);
        %         hold on;
        %         shadedErrorBar(sub.Timing,mean(squeeze(metrics.HorVek(:,exp,:,mat)),2),2*(std(squeeze(metrics.HorVek(:,exp,:,mat))')/sqrt(size(metrics.BadTrialsSub,2))),'lineprops',{'-','Color',Colormap(mat,:)})
        %         plot(sub.Timing,mean(squeeze(metrics.HorVek(:,exp,:,mat)),2),'-','Color',Colormap(mat,:),'LineWidth',2)
        %         plot(sub.Timing,squeeze(metrics.HorVekTar(:,exp,1,mat)),'-','Color',Colormap(mat,:),'LineWidth',1)
        %         xlim([-400 400])
        %         ylim([-8 4])
        %         plot([0 0],[-8 4],'k-')
        %         title(Labels{exp})
        %         xlabel('Time relative to Water Contact [ms]')
        %         ylabel('Horizontal Eye Position [dva]')

    end
end

