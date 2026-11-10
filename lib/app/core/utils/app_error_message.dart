class AppErrorMessage {
  static String userFriendly(
    Object? error, {
    String fallback = 'Something went wrong. Please try again.',
  }) {
    final rawInput = (error ?? '').toString().trim();
    if (rawInput.isEmpty) return fallback;

    final raw = rawInput.startsWith('Exception: ')
        ? rawInput.replaceFirst('Exception: ', '').trim()
        : rawInput;

    if (_looksFriendly(raw)) return raw;

    final msg = raw.toLowerCase();

    if (msg.contains('cannot destructure')) {
      return 'We could not process the server response. Please try again in a moment.';
    }
    if (msg.contains('socketexception') ||
        msg.contains('network') ||
        msg.contains('failed host lookup') ||
        msg.contains('connection refused')) {
      return 'Unable to connect right now. Please check your internet and try again.';
    }
    if (msg.contains('timeout')) {
      return 'The request took too long. Please try again.';
    }
    if (msg.contains('401') || msg.contains('unauthorized')) {
      return 'Your session has expired. Please sign in again.';
    }
    if (msg.contains('403') || msg.contains('forbidden')) {
      return 'You do not have permission to perform this action.';
    }
    if (msg.contains('404') || msg.contains('not found')) {
      return 'The requested information was not found.';
    }
    if (msg.contains('409') || msg.contains('already')) {
      return 'This action was already completed.';
    }
    if (msg.contains('500') ||
        msg.contains('internal server error') ||
        msg.contains('unexpected server response')) {
      return 'Our servers are having trouble right now. Please try again shortly.';
    }
    if (msg.contains('formatexception') ||
        msg.contains('typeerror') ||
        msg.contains('nosuchmethoderror') ||
        msg.contains('null check operator')) {
      return 'Something unexpected happened while processing your request.';
    }

    return fallback;
  }

  static bool _looksFriendly(String text) {
    final t = text.trim();
    if (t.isEmpty) return false;

    final technicalMarkers = <String>[
      'exception',
      'error:',
      'stack trace',
      'nosuchmethoderror',
      'typeerror',
      'formatexception',
      'cannot destructure',
      'null check operator',
      'failed host lookup',
      'socketexception',
      '{',
      '}',
      '[',
      ']',
    ];

    final lower = t.toLowerCase();
    for (final marker in technicalMarkers) {
      if (lower.contains(marker)) return false;
    }

    return t.length <= 180;
  }
}
