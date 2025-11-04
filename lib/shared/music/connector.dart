enum ConnectorType { spotify, appleMusic, webUpload }

extension ConnectorTypeLabel on ConnectorType {
  String get label {
    switch (this) {
      case ConnectorType.spotify:
        return 'Spotify';
      case ConnectorType.appleMusic:
        return 'Apple Music';
      case ConnectorType.webUpload:
        return 'Web Upload';
    }
  }
}
