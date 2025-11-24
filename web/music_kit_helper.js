(function () {
  const helper = {
    _configured: false,
    _music: null,
    async configure(token) {
      if (this._configured) {
        return;
      }
      if (typeof window.MusicKitLoaded !== 'undefined') {
        try {
          await window.MusicKitLoaded;
        } catch (_) {
          // ignored
        }
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
      // Capture instance for reuse.
      if (typeof MusicKit.getInstance === 'function') {
        this._music = MusicKit.getInstance();
      }
      this._configured = true;
    },
    _getMusicInstance() {
      if (this._music) {
        return this._music;
      }
      if (typeof MusicKit !== 'undefined' && typeof MusicKit.getInstance === 'function') {
        const instance = MusicKit.getInstance();
        this._music = instance;
        return instance;
      }
      return null;
    },
    async authorize() {
      if (!this._configured) {
        throw new Error('MusicKit not configured.');
      }
      // Always re-fetch the instance in case a fresh one was created.
      const music = this._getMusicInstance();
      if (!music) {
        throw new Error('MusicKit instance unavailable.');
      }
      if (music.isAuthorized && music.musicUserToken) {
        return music.musicUserToken;
      }
      // Prefer static authorize if available.
      if (typeof MusicKit !== 'undefined' && typeof MusicKit.authorize === 'function') {
        return await MusicKit.authorize();
      }
      const fresh = typeof MusicKit !== 'undefined' && typeof MusicKit.getInstance === 'function'
        ? MusicKit.getInstance()
        : music;
      if (fresh && typeof fresh.authorize === 'function') {
        return await fresh.authorize();
      }
      throw new Error('MusicKit authorize() unavailable.');
    },
    async charts() {
      const music = this._getMusicInstance();
      if (!music) {
        throw new Error('MusicKit instance unavailable.');
      }
      if (!music.api) {
        throw new Error('MusicKit API unavailable (not authorized yet).');
      }
      const result = await music.api.charts({ types: ['songs'], limit: 20 });
      return JSON.stringify(result);
    },
    async search(term) {
      const music = this._getMusicInstance();
      if (!music) {
        throw new Error('MusicKit instance unavailable.');
      }
      if (!music.api) {
        throw new Error('MusicKit API unavailable (not authorized yet).');
      }
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
