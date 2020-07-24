tic
for i = 1:100
temp = b(:,1,:);
c = b(:);
end
toc


tic
for i = 1:100
c = reshape(b(:,1,:),[],1);
end
toc