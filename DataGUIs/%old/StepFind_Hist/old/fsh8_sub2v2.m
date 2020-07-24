function Q = fsh8_sub2v2 (~, beadPos, a, history, con)
    Q = (bsxfun(@plus, beadPos, a)/(size(history,2)+1) - con).^2;