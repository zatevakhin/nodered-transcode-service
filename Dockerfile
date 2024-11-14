FROM nodered/node-red

RUN npm install \
    @node-red-contrib-themes/theme-collection \
    @kevingodell/node-red-ffmpeg \
    @steveorevo/node-red-emerge \
    @siglesiasg/node-red-event-manager \
    node-red-contrib-chronos \
    node-red-contrib-merge \
    node-red-contrib-memory-queue \
    node-red-contrib-multiple-queue \
    node-red-contrib-loop do-red

RUN cd /usr/src/node-red && npm install --save  @node-red-contrib-themes/theme-collection

USER root
RUN apk add ffmpeg
USER node-red

