function out = cdswrapper(seq)
%Wrapper for the web API for CD-Search : maybe we can automate the seq alignment search process

%EH this won't do what i want it to...

%Base API url
apiurl = 'https://www.ncbi.nlm.nih.gov/Structure/bwrpsb/bwrpsb.cgi?';

%Add params
params = {'&db=cdd' ... %Search CDD database
    sprintf('&queries=%s',seq) %Sequence
};

%Start search
rtn = webread([apiurl params{:}]);

%look for 'var ctrlHandle = "QM3-qcdsearch-203ADC8AF585709F"; ' to get ID

%Wait some time and then fetch results
pause(5);

resp = webread();