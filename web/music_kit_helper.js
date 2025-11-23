(function () {
  const helper = {
    _configured: false,
    async configure(token) {
      if (this._configured) {
        return;
      }
      if (typeof MusicKit === 'undefined') {
        throw new Error('MusicKit JS not loaded.');
      }
      MusicKit.configure({
        developerToken: token,
        app: {
          name: 'Cycle Coach',
          build: '1.0.0',
        },
      });
      this._configured = true;
    },
    async authorize() {
      const music = MusicKit.getInstance();
      return await music.authorize();
    },
    async charts() {
      const music = MusicKit.getInstance();
      const result = await music.api.charts({ types: ['songs'], limit: 20 });
      return JSON.stringify(result);
    },
    async search(term) {
      const music = MusicKit.getInstance();
      const result = await music.api.search({
        term,
        types: ['songs'],
        limit: 25,
      });
      return JSON.stringify(result);
    },
  };
  window.cycleCoachMusicKit = helper;
})();
