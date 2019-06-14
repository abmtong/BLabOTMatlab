%'interesting MATLAB puzzle' from undocumentedmatlab

function interMatPuz
    try
        if (true) 
            or 10< 9 % = or('10<', '9.9')
            disp('Yaba');
        else
            disp('Daba');
        end
    catch
        disp('Doo!');
    end
end