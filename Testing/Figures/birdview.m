function birdview()

modelB();
ax = gca;
ax.CameraPosition = [0 0 10];
ax.CameraUpVector = [-1 0 0];
print(gcf, 'upview','-dpng',sprintf('-r%d',96*2))