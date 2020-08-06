function DEMstruct=getSurveyDEM(whichThredds,fileType,varargin)
%downloads survey DEM data from the specificed Thredds server (FRF or CHL) 
%between the specified date range (startDate:endDate) or the closest survey 
%in time to a list of dates (dateList) or a single date. Will pull either
%an abreviated file with just xFRF,yFRF,Elevation, time or all of the
%variables

%inputs:
%whichTHredds = 'FRF' or 'CHL' Thredds Server
%fileType = 'xyzt' or 'full' for which data you want
%startDate = matlab datenum of start date
%endData = matlab datenum of end data
%OR
%dateList = vector of specific dates to find the closest in time survey

%outputs:
%DEMStruct = output structure with data

%example calls:
%DEMstruct = getSurveyDEM('FRF','full',startDate,endDate)
%DEMstruct = getSurveyDEM('CHL','xyzt',startDate,endDate)
%DEMstruct = getSurveyDEM('CHL','full',[date1 date2 date3])

%First figure out which thredds
if strcmp(whichThredds,'FRF')
    %internal THREDDS server
    urlDEM = 'http://134.164.129.55/thredds/dodsC/FRF/geomorphology/DEMs/surveyDEM/surveyDEM.ncml';
elseif strcmp(whichThredds,'CHL')
    %must use if NOT located at FRF
    urlDEM = 'https://chlthredds.erdc.dren.mil/thredds/dodsC/frf/geomorphology/DEMs/surveyDEM/surveyDEM.ncml';
end

%sort out date variables
if numel(varargin) == 2
    %start and end date
    startDate = varargin{1};
    endDate = varargin{2};
elseif numel(varargin) == 1
    %vector list of dates
    dateList = varargin{1};
end

%grab available variables
FINFO = ncinfo(urlDEM);

%get Time vector
dates = ncread(urlDEM,'time');
dates=dates./(60*60*24) + datenum(1970,1,1);

%find indices that we want
if exist('dateList')
    for i=1:length(dateList)
        [~,ind(i)] = min(abs(dates-dateList(i)));
    end
elseif exist('startDate') & exist('endDate')
    ind = find(dates>=startDate & dates<=endDate);
end

%make the DEMstruct
if strcmp(fileType,'full')
    DEMstruct.xFRF = ncread(urlDEM,FINFO.Variables(1).Name,1,FINFO.Variables(1).Size);
    DEMstruct.yFRF = ncread(urlDEM,FINFO.Variables(2).Name,1,FINFO.Variables(2).Size);
    DEMstruct.time = ncread(urlDEM,FINFO.Variables(3).Name,ind(1),length(ind));
    DEMstruct.surveyNum = ncread(urlDEM,FINFO.Variables(4).Name,ind(1),length(ind));
    DEMstruct.surveyVehicle = ncread(urlDEM,FINFO.Variables(5).Name,ind(1),length(ind));
    DEMstruct.project = ncread(urlDEM,FINFO.Variables(6).Name,ind(1),length(ind));
    DEMstruct.surveyInst = ncread(urlDEM,FINFO.Variables(7).Name,ind(1),length(ind));
    DEMstruct.latitude = ncread(urlDEM,FINFO.Variables(8).Name,[1 1],[inf inf]);
    DEMstruct.longitude = ncread(urlDEM,FINFO.Variables(9).Name,[1 1],[inf inf]);
    DEMstruct.northing = ncread(urlDEM,FINFO.Variables(10).Name,[1 1],[inf inf]);
    DEMstruct.easting = ncread(urlDEM,FINFO.Variables(11).Name,[1 1],[inf inf]);
    DEMstruct.elevation = ncread(urlDEM,FINFO.Variables(12).Name,[1 1 ind(1)],[inf inf length(ind)]);
elseif strcmp(fileType,'xyzt')
    DEMstruct.xFRF = ncread(urlDEM,FINFO.Variables(1).Name,1,FINFO.Variables(1).Size);
    DEMstruct.yFRF = ncread(urlDEM,FINFO.Variables(2).Name,1,FINFO.Variables(2).Size);
    DEMstruct.time = ncread(urlDEM,FINFO.Variables(3).Name,ind(1),length(ind));
    DEMstruct.elevation = ncread(urlDEM,FINFO.Variables(12).Name,[1 1 ind(1)],[inf inf length(ind)]);
end

end