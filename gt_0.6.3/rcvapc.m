%-------------------------------------------------------------------------------
% [system] : GpsTools
% [module] : receiver antenna offset
% [func]   : receiver antenna offset
% [argin]  : azel = azimuth/elevation angle(rad) [az,el]
%            apc1 = L1 phase center offset (m) [up;north;east]
%            apc2 = L2 phase center offset (m) [up;north;east]
%            ecc  = antenna deltas (m) [up;north;east]
%           (apv1) = L1 phase center variation (m) [el0;el5;el10;...;el90]
%           (apv2) = L2 phase center variation (m) [el0;el5;el10;...;el90]
% [argout] : apcr = receiver antenna offset (m) [apcr1,apcr2]
% [note]   :
% [version]: $Revision: 2 $ $Date: 06/07/08 14:19 $
%            Copyright(c) 2004-2006 by T.Takasu, all rights reserved
% [history]: 04/06/01   0.1  new
%-------------------------------------------------------------------------------

% (mex function)

