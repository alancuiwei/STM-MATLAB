function out_dataxml=ZR_FUN_CreateXMLForDailyFigure(in_date, in_value)
% …Ë∂®ª≠Õº
%	<set name='Jan' value='462'  />
%	<set name='Feb' value='857' />
%	<set name='Mar' value='671'  />
%	<set name='Apr' value='494'  />
%	<set name='May' value='761' />
%	<set name='Jun' value='960'  />
%	<set name='Jul' value='629'  />
%	<set name='Aug' value='622'  />
%	<set name='Sep' value='376' />
%	<set name='Oct' value='494'  />
%	<set name='Nov' value='761'  />
%	<set name='Dec' value='960' />

for l_id=1:length(in_value)
    out_dataxml(l_id).ATTRIBUTE.name=datestr(in_date+l_id-1);
    out_dataxml(l_id).ATTRIBUTE.value=in_value(l_id);
end
end