function xi = findStepHMMV1c_ccode_xiV2(tr, al, a, y, be, lb, ub, wid, lb2, maxwid2, sig)
%slower than V1, ignoring for now

%declare output
len = length(tr);
lena = length(a);
% hei = length(y);

xi = zeros(1, lena);
% tempal = zeros(1,maxwid2);
% tempbe = zeros(1,maxwid2);
for t = 1:len-1
    %alpha, beta
%     tempal = 0*tempal;
%     tempal(lb(t)-lb2(t)+1:ub(t)-lb2(t)+1) = al(t,1:wid(t));
%     tempbe = 0*tempbe;
    tempb = normpdf(y(lb(t+1):ub(t+1)), tr(t+1), sig);
%     tempbe(lb(t+1)-lb2(t)+1:ub(t+1)-lb2(t)+1) = be(t+1,1:wid(t+1));
    tempxi = zeros(1,lena);
    for i = 1:maxwid2
        for j = 1:maxwid2
            ind = j - i + 1;
            if ind > 0 && ind <= lena
                %check if i is in bounds
                indi = lb(t)-lb2(t)+i;
                if indi >= 1 && indi <= wid(t)
                    %check if j is in bounds
                    indj = lb(t+1)-lb2(t) + j;
                    if indj >= 1 && indj <= wid(t+1);
                        %tempxi(ind) = tempxi(ind) + tempal(i) * a(ind) * tempb(j) * tempbe(j);
                        tempxi(ind) = tempxi(ind) + al(t, indi) * a(ind) * tempb(indj) * be(t, indj);
                    end
                end
            end
        end
    end
    xi = xi + tempxi / sum(tempxi);
    
    
    
    
    %     %temp sum vector
    %     txi = zeros(wid);
    %     %calc npdf

    %     for i = 1:wid
    %         dw = lb(i+1)-lb(i);
    %         for j = 1:wid
    %             %check if a is in frame
    %             if j - i > 0 && j - i <= lena
    %                 %check if b is in frame w.r.t. a
    %                 jn = dw + i - j;
    %                 if dw + i - j >= 0
    %                     %check if b is not out of width
    %
    %                     txi(i,j) = al(t, i) * a(j+dw-i) * b(j+dw+lb(t+1)-1) * be(t+1, j+dw);
    %                 end
    %             end
    %         end
    %     end
    % %     txi = txi / sum(txi);
    %     xi = xi + txi/sum(txi(:));
end