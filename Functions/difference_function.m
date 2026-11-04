function [dev]= difference(p,y_emp,x)

y_pred= LearningCurve(p,x); % Get the predictions with the respective model parameter


dev= nansum(((y_emp(:))-(y_pred(:))).^2); % Compute squared error between prediction and empirical data
% --> This will be minimized

