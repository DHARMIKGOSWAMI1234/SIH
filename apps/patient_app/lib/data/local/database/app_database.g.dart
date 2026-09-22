// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $GameSessionsTable extends GameSessions
    with TableInfo<$GameSessionsTable, GameSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GameSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<String> localId = GeneratedColumn<String>(
    'local_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _gameTypeMeta = const VerificationMeta(
    'gameType',
  );
  @override
  late final GeneratedColumn<String> gameType = GeneratedColumn<String>(
    'game_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<int> score = GeneratedColumn<int>(
    'score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accuracyMeta = const VerificationMeta(
    'accuracy',
  );
  @override
  late final GeneratedColumn<double> accuracy = GeneratedColumn<double>(
    'accuracy',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mistakesMeta = const VerificationMeta(
    'mistakes',
  );
  @override
  late final GeneratedColumn<int> mistakes = GeneratedColumn<int>(
    'mistakes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _responseTimeMsMeta = const VerificationMeta(
    'responseTimeMs',
  );
  @override
  late final GeneratedColumn<double> responseTimeMs = GeneratedColumn<double>(
    'response_time_ms',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _difficultyMeta = const VerificationMeta(
    'difficulty',
  );
  @override
  late final GeneratedColumn<int> difficulty = GeneratedColumn<int>(
    'difficulty',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hintCountMeta = const VerificationMeta(
    'hintCount',
  );
  @override
  late final GeneratedColumn<int> hintCount = GeneratedColumn<int>(
    'hint_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<DateTime> completedAt = GeneratedColumn<DateTime>(
    'completed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    localId,
    serverId,
    gameType,
    score,
    accuracy,
    mistakes,
    responseTimeMs,
    difficulty,
    hintCount,
    startedAt,
    completedAt,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'game_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<GameSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    } else if (isInserting) {
      context.missing(_localIdMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('game_type')) {
      context.handle(
        _gameTypeMeta,
        gameType.isAcceptableOrUnknown(data['game_type']!, _gameTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_gameTypeMeta);
    }
    if (data.containsKey('score')) {
      context.handle(
        _scoreMeta,
        score.isAcceptableOrUnknown(data['score']!, _scoreMeta),
      );
    } else if (isInserting) {
      context.missing(_scoreMeta);
    }
    if (data.containsKey('accuracy')) {
      context.handle(
        _accuracyMeta,
        accuracy.isAcceptableOrUnknown(data['accuracy']!, _accuracyMeta),
      );
    } else if (isInserting) {
      context.missing(_accuracyMeta);
    }
    if (data.containsKey('mistakes')) {
      context.handle(
        _mistakesMeta,
        mistakes.isAcceptableOrUnknown(data['mistakes']!, _mistakesMeta),
      );
    } else if (isInserting) {
      context.missing(_mistakesMeta);
    }
    if (data.containsKey('response_time_ms')) {
      context.handle(
        _responseTimeMsMeta,
        responseTimeMs.isAcceptableOrUnknown(
          data['response_time_ms']!,
          _responseTimeMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_responseTimeMsMeta);
    }
    if (data.containsKey('difficulty')) {
      context.handle(
        _difficultyMeta,
        difficulty.isAcceptableOrUnknown(data['difficulty']!, _difficultyMeta),
      );
    } else if (isInserting) {
      context.missing(_difficultyMeta);
    }
    if (data.containsKey('hint_count')) {
      context.handle(
        _hintCountMeta,
        hintCount.isAcceptableOrUnknown(data['hint_count']!, _hintCountMeta),
      );
    } else if (isInserting) {
      context.missing(_hintCountMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completedAtMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  GameSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GameSession(
      localId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_id'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_id'],
      ),
      gameType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}game_type'],
      )!,
      score: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}score'],
      )!,
      accuracy: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}accuracy'],
      )!,
      mistakes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mistakes'],
      )!,
      responseTimeMs: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}response_time_ms'],
      )!,
      difficulty: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}difficulty'],
      )!,
      hintCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}hint_count'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}completed_at'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
    );
  }

  @override
  $GameSessionsTable createAlias(String alias) {
    return $GameSessionsTable(attachedDatabase, alias);
  }
}

class GameSession extends DataClass implements Insertable<GameSession> {
  final String localId;
  final String? serverId;
  final String gameType;
  final int score;
  final double accuracy;
  final int mistakes;
  final double responseTimeMs;
  final int difficulty;
  final int hintCount;
  final DateTime startedAt;
  final DateTime completedAt;
  final String syncStatus;
  const GameSession({
    required this.localId,
    this.serverId,
    required this.gameType,
    required this.score,
    required this.accuracy,
    required this.mistakes,
    required this.responseTimeMs,
    required this.difficulty,
    required this.hintCount,
    required this.startedAt,
    required this.completedAt,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<String>(localId);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    map['game_type'] = Variable<String>(gameType);
    map['score'] = Variable<int>(score);
    map['accuracy'] = Variable<double>(accuracy);
    map['mistakes'] = Variable<int>(mistakes);
    map['response_time_ms'] = Variable<double>(responseTimeMs);
    map['difficulty'] = Variable<int>(difficulty);
    map['hint_count'] = Variable<int>(hintCount);
    map['started_at'] = Variable<DateTime>(startedAt);
    map['completed_at'] = Variable<DateTime>(completedAt);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  GameSessionsCompanion toCompanion(bool nullToAbsent) {
    return GameSessionsCompanion(
      localId: Value(localId),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      gameType: Value(gameType),
      score: Value(score),
      accuracy: Value(accuracy),
      mistakes: Value(mistakes),
      responseTimeMs: Value(responseTimeMs),
      difficulty: Value(difficulty),
      hintCount: Value(hintCount),
      startedAt: Value(startedAt),
      completedAt: Value(completedAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory GameSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GameSession(
      localId: serializer.fromJson<String>(json['localId']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      gameType: serializer.fromJson<String>(json['gameType']),
      score: serializer.fromJson<int>(json['score']),
      accuracy: serializer.fromJson<double>(json['accuracy']),
      mistakes: serializer.fromJson<int>(json['mistakes']),
      responseTimeMs: serializer.fromJson<double>(json['responseTimeMs']),
      difficulty: serializer.fromJson<int>(json['difficulty']),
      hintCount: serializer.fromJson<int>(json['hintCount']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      completedAt: serializer.fromJson<DateTime>(json['completedAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<String>(localId),
      'serverId': serializer.toJson<String?>(serverId),
      'gameType': serializer.toJson<String>(gameType),
      'score': serializer.toJson<int>(score),
      'accuracy': serializer.toJson<double>(accuracy),
      'mistakes': serializer.toJson<int>(mistakes),
      'responseTimeMs': serializer.toJson<double>(responseTimeMs),
      'difficulty': serializer.toJson<int>(difficulty),
      'hintCount': serializer.toJson<int>(hintCount),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'completedAt': serializer.toJson<DateTime>(completedAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  GameSession copyWith({
    String? localId,
    Value<String?> serverId = const Value.absent(),
    String? gameType,
    int? score,
    double? accuracy,
    int? mistakes,
    double? responseTimeMs,
    int? difficulty,
    int? hintCount,
    DateTime? startedAt,
    DateTime? completedAt,
    String? syncStatus,
  }) => GameSession(
    localId: localId ?? this.localId,
    serverId: serverId.present ? serverId.value : this.serverId,
    gameType: gameType ?? this.gameType,
    score: score ?? this.score,
    accuracy: accuracy ?? this.accuracy,
    mistakes: mistakes ?? this.mistakes,
    responseTimeMs: responseTimeMs ?? this.responseTimeMs,
    difficulty: difficulty ?? this.difficulty,
    hintCount: hintCount ?? this.hintCount,
    startedAt: startedAt ?? this.startedAt,
    completedAt: completedAt ?? this.completedAt,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  GameSession copyWithCompanion(GameSessionsCompanion data) {
    return GameSession(
      localId: data.localId.present ? data.localId.value : this.localId,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      gameType: data.gameType.present ? data.gameType.value : this.gameType,
      score: data.score.present ? data.score.value : this.score,
      accuracy: data.accuracy.present ? data.accuracy.value : this.accuracy,
      mistakes: data.mistakes.present ? data.mistakes.value : this.mistakes,
      responseTimeMs: data.responseTimeMs.present
          ? data.responseTimeMs.value
          : this.responseTimeMs,
      difficulty: data.difficulty.present
          ? data.difficulty.value
          : this.difficulty,
      hintCount: data.hintCount.present ? data.hintCount.value : this.hintCount,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GameSession(')
          ..write('localId: $localId, ')
          ..write('serverId: $serverId, ')
          ..write('gameType: $gameType, ')
          ..write('score: $score, ')
          ..write('accuracy: $accuracy, ')
          ..write('mistakes: $mistakes, ')
          ..write('responseTimeMs: $responseTimeMs, ')
          ..write('difficulty: $difficulty, ')
          ..write('hintCount: $hintCount, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    localId,
    serverId,
    gameType,
    score,
    accuracy,
    mistakes,
    responseTimeMs,
    difficulty,
    hintCount,
    startedAt,
    completedAt,
    syncStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GameSession &&
          other.localId == this.localId &&
          other.serverId == this.serverId &&
          other.gameType == this.gameType &&
          other.score == this.score &&
          other.accuracy == this.accuracy &&
          other.mistakes == this.mistakes &&
          other.responseTimeMs == this.responseTimeMs &&
          other.difficulty == this.difficulty &&
          other.hintCount == this.hintCount &&
          other.startedAt == this.startedAt &&
          other.completedAt == this.completedAt &&
          other.syncStatus == this.syncStatus);
}

class GameSessionsCompanion extends UpdateCompanion<GameSession> {
  final Value<String> localId;
  final Value<String?> serverId;
  final Value<String> gameType;
  final Value<int> score;
  final Value<double> accuracy;
  final Value<int> mistakes;
  final Value<double> responseTimeMs;
  final Value<int> difficulty;
  final Value<int> hintCount;
  final Value<DateTime> startedAt;
  final Value<DateTime> completedAt;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const GameSessionsCompanion({
    this.localId = const Value.absent(),
    this.serverId = const Value.absent(),
    this.gameType = const Value.absent(),
    this.score = const Value.absent(),
    this.accuracy = const Value.absent(),
    this.mistakes = const Value.absent(),
    this.responseTimeMs = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.hintCount = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GameSessionsCompanion.insert({
    required String localId,
    this.serverId = const Value.absent(),
    required String gameType,
    required int score,
    required double accuracy,
    required int mistakes,
    required double responseTimeMs,
    required int difficulty,
    required int hintCount,
    required DateTime startedAt,
    required DateTime completedAt,
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : localId = Value(localId),
       gameType = Value(gameType),
       score = Value(score),
       accuracy = Value(accuracy),
       mistakes = Value(mistakes),
       responseTimeMs = Value(responseTimeMs),
       difficulty = Value(difficulty),
       hintCount = Value(hintCount),
       startedAt = Value(startedAt),
       completedAt = Value(completedAt);
  static Insertable<GameSession> custom({
    Expression<String>? localId,
    Expression<String>? serverId,
    Expression<String>? gameType,
    Expression<int>? score,
    Expression<double>? accuracy,
    Expression<int>? mistakes,
    Expression<double>? responseTimeMs,
    Expression<int>? difficulty,
    Expression<int>? hintCount,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? completedAt,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (serverId != null) 'server_id': serverId,
      if (gameType != null) 'game_type': gameType,
      if (score != null) 'score': score,
      if (accuracy != null) 'accuracy': accuracy,
      if (mistakes != null) 'mistakes': mistakes,
      if (responseTimeMs != null) 'response_time_ms': responseTimeMs,
      if (difficulty != null) 'difficulty': difficulty,
      if (hintCount != null) 'hint_count': hintCount,
      if (startedAt != null) 'started_at': startedAt,
      if (completedAt != null) 'completed_at': completedAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GameSessionsCompanion copyWith({
    Value<String>? localId,
    Value<String?>? serverId,
    Value<String>? gameType,
    Value<int>? score,
    Value<double>? accuracy,
    Value<int>? mistakes,
    Value<double>? responseTimeMs,
    Value<int>? difficulty,
    Value<int>? hintCount,
    Value<DateTime>? startedAt,
    Value<DateTime>? completedAt,
    Value<String>? syncStatus,
    Value<int>? rowid,
  }) {
    return GameSessionsCompanion(
      localId: localId ?? this.localId,
      serverId: serverId ?? this.serverId,
      gameType: gameType ?? this.gameType,
      score: score ?? this.score,
      accuracy: accuracy ?? this.accuracy,
      mistakes: mistakes ?? this.mistakes,
      responseTimeMs: responseTimeMs ?? this.responseTimeMs,
      difficulty: difficulty ?? this.difficulty,
      hintCount: hintCount ?? this.hintCount,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<String>(localId.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (gameType.present) {
      map['game_type'] = Variable<String>(gameType.value);
    }
    if (score.present) {
      map['score'] = Variable<int>(score.value);
    }
    if (accuracy.present) {
      map['accuracy'] = Variable<double>(accuracy.value);
    }
    if (mistakes.present) {
      map['mistakes'] = Variable<int>(mistakes.value);
    }
    if (responseTimeMs.present) {
      map['response_time_ms'] = Variable<double>(responseTimeMs.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<int>(difficulty.value);
    }
    if (hintCount.present) {
      map['hint_count'] = Variable<int>(hintCount.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<DateTime>(completedAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GameSessionsCompanion(')
          ..write('localId: $localId, ')
          ..write('serverId: $serverId, ')
          ..write('gameType: $gameType, ')
          ..write('score: $score, ')
          ..write('accuracy: $accuracy, ')
          ..write('mistakes: $mistakes, ')
          ..write('responseTimeMs: $responseTimeMs, ')
          ..write('difficulty: $difficulty, ')
          ..write('hintCount: $hintCount, ')
          ..write('startedAt: $startedAt, ')
          ..write('completedAt: $completedAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RemindersTable extends Reminders
    with TableInfo<$RemindersTable, Reminder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RemindersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<String> localId = GeneratedColumn<String>(
    'local_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reminderTypeMeta = const VerificationMeta(
    'reminderType',
  );
  @override
  late final GeneratedColumn<String> reminderType = GeneratedColumn<String>(
    'reminder_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scheduledTimeMeta = const VerificationMeta(
    'scheduledTime',
  );
  @override
  late final GeneratedColumn<String> scheduledTime = GeneratedColumn<String>(
    'scheduled_time',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    localId,
    serverId,
    title,
    reminderType,
    scheduledTime,
    enabled,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reminders';
  @override
  VerificationContext validateIntegrity(
    Insertable<Reminder> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    } else if (isInserting) {
      context.missing(_localIdMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('reminder_type')) {
      context.handle(
        _reminderTypeMeta,
        reminderType.isAcceptableOrUnknown(
          data['reminder_type']!,
          _reminderTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_reminderTypeMeta);
    }
    if (data.containsKey('scheduled_time')) {
      context.handle(
        _scheduledTimeMeta,
        scheduledTime.isAcceptableOrUnknown(
          data['scheduled_time']!,
          _scheduledTimeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scheduledTimeMeta);
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  Reminder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Reminder(
      localId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_id'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_id'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      reminderType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reminder_type'],
      )!,
      scheduledTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}scheduled_time'],
      )!,
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
    );
  }

  @override
  $RemindersTable createAlias(String alias) {
    return $RemindersTable(attachedDatabase, alias);
  }
}

class Reminder extends DataClass implements Insertable<Reminder> {
  final String localId;
  final String? serverId;
  final String title;
  final String reminderType;
  final String scheduledTime;
  final bool enabled;
  final String syncStatus;
  const Reminder({
    required this.localId,
    this.serverId,
    required this.title,
    required this.reminderType,
    required this.scheduledTime,
    required this.enabled,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<String>(localId);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    map['title'] = Variable<String>(title);
    map['reminder_type'] = Variable<String>(reminderType);
    map['scheduled_time'] = Variable<String>(scheduledTime);
    map['enabled'] = Variable<bool>(enabled);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  RemindersCompanion toCompanion(bool nullToAbsent) {
    return RemindersCompanion(
      localId: Value(localId),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      title: Value(title),
      reminderType: Value(reminderType),
      scheduledTime: Value(scheduledTime),
      enabled: Value(enabled),
      syncStatus: Value(syncStatus),
    );
  }

  factory Reminder.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Reminder(
      localId: serializer.fromJson<String>(json['localId']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      title: serializer.fromJson<String>(json['title']),
      reminderType: serializer.fromJson<String>(json['reminderType']),
      scheduledTime: serializer.fromJson<String>(json['scheduledTime']),
      enabled: serializer.fromJson<bool>(json['enabled']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<String>(localId),
      'serverId': serializer.toJson<String?>(serverId),
      'title': serializer.toJson<String>(title),
      'reminderType': serializer.toJson<String>(reminderType),
      'scheduledTime': serializer.toJson<String>(scheduledTime),
      'enabled': serializer.toJson<bool>(enabled),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  Reminder copyWith({
    String? localId,
    Value<String?> serverId = const Value.absent(),
    String? title,
    String? reminderType,
    String? scheduledTime,
    bool? enabled,
    String? syncStatus,
  }) => Reminder(
    localId: localId ?? this.localId,
    serverId: serverId.present ? serverId.value : this.serverId,
    title: title ?? this.title,
    reminderType: reminderType ?? this.reminderType,
    scheduledTime: scheduledTime ?? this.scheduledTime,
    enabled: enabled ?? this.enabled,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  Reminder copyWithCompanion(RemindersCompanion data) {
    return Reminder(
      localId: data.localId.present ? data.localId.value : this.localId,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      title: data.title.present ? data.title.value : this.title,
      reminderType: data.reminderType.present
          ? data.reminderType.value
          : this.reminderType,
      scheduledTime: data.scheduledTime.present
          ? data.scheduledTime.value
          : this.scheduledTime,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Reminder(')
          ..write('localId: $localId, ')
          ..write('serverId: $serverId, ')
          ..write('title: $title, ')
          ..write('reminderType: $reminderType, ')
          ..write('scheduledTime: $scheduledTime, ')
          ..write('enabled: $enabled, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    localId,
    serverId,
    title,
    reminderType,
    scheduledTime,
    enabled,
    syncStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Reminder &&
          other.localId == this.localId &&
          other.serverId == this.serverId &&
          other.title == this.title &&
          other.reminderType == this.reminderType &&
          other.scheduledTime == this.scheduledTime &&
          other.enabled == this.enabled &&
          other.syncStatus == this.syncStatus);
}

class RemindersCompanion extends UpdateCompanion<Reminder> {
  final Value<String> localId;
  final Value<String?> serverId;
  final Value<String> title;
  final Value<String> reminderType;
  final Value<String> scheduledTime;
  final Value<bool> enabled;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const RemindersCompanion({
    this.localId = const Value.absent(),
    this.serverId = const Value.absent(),
    this.title = const Value.absent(),
    this.reminderType = const Value.absent(),
    this.scheduledTime = const Value.absent(),
    this.enabled = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RemindersCompanion.insert({
    required String localId,
    this.serverId = const Value.absent(),
    required String title,
    required String reminderType,
    required String scheduledTime,
    this.enabled = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : localId = Value(localId),
       title = Value(title),
       reminderType = Value(reminderType),
       scheduledTime = Value(scheduledTime);
  static Insertable<Reminder> custom({
    Expression<String>? localId,
    Expression<String>? serverId,
    Expression<String>? title,
    Expression<String>? reminderType,
    Expression<String>? scheduledTime,
    Expression<bool>? enabled,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (serverId != null) 'server_id': serverId,
      if (title != null) 'title': title,
      if (reminderType != null) 'reminder_type': reminderType,
      if (scheduledTime != null) 'scheduled_time': scheduledTime,
      if (enabled != null) 'enabled': enabled,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RemindersCompanion copyWith({
    Value<String>? localId,
    Value<String?>? serverId,
    Value<String>? title,
    Value<String>? reminderType,
    Value<String>? scheduledTime,
    Value<bool>? enabled,
    Value<String>? syncStatus,
    Value<int>? rowid,
  }) {
    return RemindersCompanion(
      localId: localId ?? this.localId,
      serverId: serverId ?? this.serverId,
      title: title ?? this.title,
      reminderType: reminderType ?? this.reminderType,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      enabled: enabled ?? this.enabled,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<String>(localId.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (reminderType.present) {
      map['reminder_type'] = Variable<String>(reminderType.value);
    }
    if (scheduledTime.present) {
      map['scheduled_time'] = Variable<String>(scheduledTime.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RemindersCompanion(')
          ..write('localId: $localId, ')
          ..write('serverId: $serverId, ')
          ..write('title: $title, ')
          ..write('reminderType: $reminderType, ')
          ..write('scheduledTime: $scheduledTime, ')
          ..write('enabled: $enabled, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReminderEventsTable extends ReminderEvents
    with TableInfo<$ReminderEventsTable, ReminderEvent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReminderEventsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<String> localId = GeneratedColumn<String>(
    'local_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reminderIdMeta = const VerificationMeta(
    'reminderId',
  );
  @override
  late final GeneratedColumn<String> reminderId = GeneratedColumn<String>(
    'reminder_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventTypeMeta = const VerificationMeta(
    'eventType',
  );
  @override
  late final GeneratedColumn<String> eventType = GeneratedColumn<String>(
    'event_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    localId,
    reminderId,
    eventType,
    occurredAt,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reminder_events';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReminderEvent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    } else if (isInserting) {
      context.missing(_localIdMeta);
    }
    if (data.containsKey('reminder_id')) {
      context.handle(
        _reminderIdMeta,
        reminderId.isAcceptableOrUnknown(data['reminder_id']!, _reminderIdMeta),
      );
    } else if (isInserting) {
      context.missing(_reminderIdMeta);
    }
    if (data.containsKey('event_type')) {
      context.handle(
        _eventTypeMeta,
        eventType.isAcceptableOrUnknown(data['event_type']!, _eventTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_eventTypeMeta);
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  ReminderEvent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReminderEvent(
      localId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_id'],
      )!,
      reminderId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reminder_id'],
      )!,
      eventType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_type'],
      )!,
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
    );
  }

  @override
  $ReminderEventsTable createAlias(String alias) {
    return $ReminderEventsTable(attachedDatabase, alias);
  }
}

class ReminderEvent extends DataClass implements Insertable<ReminderEvent> {
  final String localId;
  final String reminderId;
  final String eventType;
  final DateTime occurredAt;
  final String syncStatus;
  const ReminderEvent({
    required this.localId,
    required this.reminderId,
    required this.eventType,
    required this.occurredAt,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<String>(localId);
    map['reminder_id'] = Variable<String>(reminderId);
    map['event_type'] = Variable<String>(eventType);
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  ReminderEventsCompanion toCompanion(bool nullToAbsent) {
    return ReminderEventsCompanion(
      localId: Value(localId),
      reminderId: Value(reminderId),
      eventType: Value(eventType),
      occurredAt: Value(occurredAt),
      syncStatus: Value(syncStatus),
    );
  }

  factory ReminderEvent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReminderEvent(
      localId: serializer.fromJson<String>(json['localId']),
      reminderId: serializer.fromJson<String>(json['reminderId']),
      eventType: serializer.fromJson<String>(json['eventType']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<String>(localId),
      'reminderId': serializer.toJson<String>(reminderId),
      'eventType': serializer.toJson<String>(eventType),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  ReminderEvent copyWith({
    String? localId,
    String? reminderId,
    String? eventType,
    DateTime? occurredAt,
    String? syncStatus,
  }) => ReminderEvent(
    localId: localId ?? this.localId,
    reminderId: reminderId ?? this.reminderId,
    eventType: eventType ?? this.eventType,
    occurredAt: occurredAt ?? this.occurredAt,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  ReminderEvent copyWithCompanion(ReminderEventsCompanion data) {
    return ReminderEvent(
      localId: data.localId.present ? data.localId.value : this.localId,
      reminderId: data.reminderId.present
          ? data.reminderId.value
          : this.reminderId,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReminderEvent(')
          ..write('localId: $localId, ')
          ..write('reminderId: $reminderId, ')
          ..write('eventType: $eventType, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(localId, reminderId, eventType, occurredAt, syncStatus);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReminderEvent &&
          other.localId == this.localId &&
          other.reminderId == this.reminderId &&
          other.eventType == this.eventType &&
          other.occurredAt == this.occurredAt &&
          other.syncStatus == this.syncStatus);
}

class ReminderEventsCompanion extends UpdateCompanion<ReminderEvent> {
  final Value<String> localId;
  final Value<String> reminderId;
  final Value<String> eventType;
  final Value<DateTime> occurredAt;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const ReminderEventsCompanion({
    this.localId = const Value.absent(),
    this.reminderId = const Value.absent(),
    this.eventType = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReminderEventsCompanion.insert({
    required String localId,
    required String reminderId,
    required String eventType,
    required DateTime occurredAt,
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : localId = Value(localId),
       reminderId = Value(reminderId),
       eventType = Value(eventType),
       occurredAt = Value(occurredAt);
  static Insertable<ReminderEvent> custom({
    Expression<String>? localId,
    Expression<String>? reminderId,
    Expression<String>? eventType,
    Expression<DateTime>? occurredAt,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (reminderId != null) 'reminder_id': reminderId,
      if (eventType != null) 'event_type': eventType,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReminderEventsCompanion copyWith({
    Value<String>? localId,
    Value<String>? reminderId,
    Value<String>? eventType,
    Value<DateTime>? occurredAt,
    Value<String>? syncStatus,
    Value<int>? rowid,
  }) {
    return ReminderEventsCompanion(
      localId: localId ?? this.localId,
      reminderId: reminderId ?? this.reminderId,
      eventType: eventType ?? this.eventType,
      occurredAt: occurredAt ?? this.occurredAt,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<String>(localId.value);
    }
    if (reminderId.present) {
      map['reminder_id'] = Variable<String>(reminderId.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(eventType.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReminderEventsCompanion(')
          ..write('localId: $localId, ')
          ..write('reminderId: $reminderId, ')
          ..write('eventType: $eventType, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RoutinesTable extends Routines with TableInfo<$RoutinesTable, Routine> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RoutinesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<String> localId = GeneratedColumn<String>(
    'local_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stepsJsonMeta = const VerificationMeta(
    'stepsJson',
  );
  @override
  late final GeneratedColumn<String> stepsJson = GeneratedColumn<String>(
    'steps_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _preferredTimeMeta = const VerificationMeta(
    'preferredTime',
  );
  @override
  late final GeneratedColumn<String> preferredTime = GeneratedColumn<String>(
    'preferred_time',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    localId,
    serverId,
    title,
    stepsJson,
    preferredTime,
    enabled,
    syncStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'routines';
  @override
  VerificationContext validateIntegrity(
    Insertable<Routine> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    } else if (isInserting) {
      context.missing(_localIdMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('steps_json')) {
      context.handle(
        _stepsJsonMeta,
        stepsJson.isAcceptableOrUnknown(data['steps_json']!, _stepsJsonMeta),
      );
    } else if (isInserting) {
      context.missing(_stepsJsonMeta);
    }
    if (data.containsKey('preferred_time')) {
      context.handle(
        _preferredTimeMeta,
        preferredTime.isAcceptableOrUnknown(
          data['preferred_time']!,
          _preferredTimeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_preferredTimeMeta);
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  Routine map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Routine(
      localId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_id'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_id'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      stepsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}steps_json'],
      )!,
      preferredTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}preferred_time'],
      )!,
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
    );
  }

  @override
  $RoutinesTable createAlias(String alias) {
    return $RoutinesTable(attachedDatabase, alias);
  }
}

class Routine extends DataClass implements Insertable<Routine> {
  final String localId;
  final String? serverId;
  final String title;
  final String stepsJson;
  final String preferredTime;
  final bool enabled;
  final String syncStatus;
  const Routine({
    required this.localId,
    this.serverId,
    required this.title,
    required this.stepsJson,
    required this.preferredTime,
    required this.enabled,
    required this.syncStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<String>(localId);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    map['title'] = Variable<String>(title);
    map['steps_json'] = Variable<String>(stepsJson);
    map['preferred_time'] = Variable<String>(preferredTime);
    map['enabled'] = Variable<bool>(enabled);
    map['sync_status'] = Variable<String>(syncStatus);
    return map;
  }

  RoutinesCompanion toCompanion(bool nullToAbsent) {
    return RoutinesCompanion(
      localId: Value(localId),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      title: Value(title),
      stepsJson: Value(stepsJson),
      preferredTime: Value(preferredTime),
      enabled: Value(enabled),
      syncStatus: Value(syncStatus),
    );
  }

  factory Routine.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Routine(
      localId: serializer.fromJson<String>(json['localId']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      title: serializer.fromJson<String>(json['title']),
      stepsJson: serializer.fromJson<String>(json['stepsJson']),
      preferredTime: serializer.fromJson<String>(json['preferredTime']),
      enabled: serializer.fromJson<bool>(json['enabled']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<String>(localId),
      'serverId': serializer.toJson<String?>(serverId),
      'title': serializer.toJson<String>(title),
      'stepsJson': serializer.toJson<String>(stepsJson),
      'preferredTime': serializer.toJson<String>(preferredTime),
      'enabled': serializer.toJson<bool>(enabled),
      'syncStatus': serializer.toJson<String>(syncStatus),
    };
  }

  Routine copyWith({
    String? localId,
    Value<String?> serverId = const Value.absent(),
    String? title,
    String? stepsJson,
    String? preferredTime,
    bool? enabled,
    String? syncStatus,
  }) => Routine(
    localId: localId ?? this.localId,
    serverId: serverId.present ? serverId.value : this.serverId,
    title: title ?? this.title,
    stepsJson: stepsJson ?? this.stepsJson,
    preferredTime: preferredTime ?? this.preferredTime,
    enabled: enabled ?? this.enabled,
    syncStatus: syncStatus ?? this.syncStatus,
  );
  Routine copyWithCompanion(RoutinesCompanion data) {
    return Routine(
      localId: data.localId.present ? data.localId.value : this.localId,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      title: data.title.present ? data.title.value : this.title,
      stepsJson: data.stepsJson.present ? data.stepsJson.value : this.stepsJson,
      preferredTime: data.preferredTime.present
          ? data.preferredTime.value
          : this.preferredTime,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Routine(')
          ..write('localId: $localId, ')
          ..write('serverId: $serverId, ')
          ..write('title: $title, ')
          ..write('stepsJson: $stepsJson, ')
          ..write('preferredTime: $preferredTime, ')
          ..write('enabled: $enabled, ')
          ..write('syncStatus: $syncStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    localId,
    serverId,
    title,
    stepsJson,
    preferredTime,
    enabled,
    syncStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Routine &&
          other.localId == this.localId &&
          other.serverId == this.serverId &&
          other.title == this.title &&
          other.stepsJson == this.stepsJson &&
          other.preferredTime == this.preferredTime &&
          other.enabled == this.enabled &&
          other.syncStatus == this.syncStatus);
}

class RoutinesCompanion extends UpdateCompanion<Routine> {
  final Value<String> localId;
  final Value<String?> serverId;
  final Value<String> title;
  final Value<String> stepsJson;
  final Value<String> preferredTime;
  final Value<bool> enabled;
  final Value<String> syncStatus;
  final Value<int> rowid;
  const RoutinesCompanion({
    this.localId = const Value.absent(),
    this.serverId = const Value.absent(),
    this.title = const Value.absent(),
    this.stepsJson = const Value.absent(),
    this.preferredTime = const Value.absent(),
    this.enabled = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RoutinesCompanion.insert({
    required String localId,
    this.serverId = const Value.absent(),
    required String title,
    required String stepsJson,
    required String preferredTime,
    this.enabled = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : localId = Value(localId),
       title = Value(title),
       stepsJson = Value(stepsJson),
       preferredTime = Value(preferredTime);
  static Insertable<Routine> custom({
    Expression<String>? localId,
    Expression<String>? serverId,
    Expression<String>? title,
    Expression<String>? stepsJson,
    Expression<String>? preferredTime,
    Expression<bool>? enabled,
    Expression<String>? syncStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (serverId != null) 'server_id': serverId,
      if (title != null) 'title': title,
      if (stepsJson != null) 'steps_json': stepsJson,
      if (preferredTime != null) 'preferred_time': preferredTime,
      if (enabled != null) 'enabled': enabled,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RoutinesCompanion copyWith({
    Value<String>? localId,
    Value<String?>? serverId,
    Value<String>? title,
    Value<String>? stepsJson,
    Value<String>? preferredTime,
    Value<bool>? enabled,
    Value<String>? syncStatus,
    Value<int>? rowid,
  }) {
    return RoutinesCompanion(
      localId: localId ?? this.localId,
      serverId: serverId ?? this.serverId,
      title: title ?? this.title,
      stepsJson: stepsJson ?? this.stepsJson,
      preferredTime: preferredTime ?? this.preferredTime,
      enabled: enabled ?? this.enabled,
      syncStatus: syncStatus ?? this.syncStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<String>(localId.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (stepsJson.present) {
      map['steps_json'] = Variable<String>(stepsJson.value);
    }
    if (preferredTime.present) {
      map['preferred_time'] = Variable<String>(preferredTime.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RoutinesCompanion(')
          ..write('localId: $localId, ')
          ..write('serverId: $serverId, ')
          ..write('title: $title, ')
          ..write('stepsJson: $stepsJson, ')
          ..write('preferredTime: $preferredTime, ')
          ..write('enabled: $enabled, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MemoriesTable extends Memories with TableInfo<$MemoriesTable, Memory> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MemoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<String> localId = GeneratedColumn<String>(
    'local_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _serverIdMeta = const VerificationMeta(
    'serverId',
  );
  @override
  late final GeneratedColumn<String> serverId = GeneratedColumn<String>(
    'server_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mediaUriMeta = const VerificationMeta(
    'mediaUri',
  );
  @override
  late final GeneratedColumn<String> mediaUri = GeneratedColumn<String>(
    'media_uri',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('other'),
  );
  static const VerificationMeta _relationshipMeta = const VerificationMeta(
    'relationship',
  );
  @override
  late final GeneratedColumn<String> relationship = GeneratedColumn<String>(
    'relationship',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _personNameMeta = const VerificationMeta(
    'personName',
  );
  @override
  late final GeneratedColumn<String> personName = GeneratedColumn<String>(
    'person_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _eventDateMeta = const VerificationMeta(
    'eventDate',
  );
  @override
  late final GeneratedColumn<DateTime> eventDate = GeneratedColumn<DateTime>(
    'event_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _imagePathMeta = const VerificationMeta(
    'imagePath',
  );
  @override
  late final GeneratedColumn<String> imagePath = GeneratedColumn<String>(
    'image_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _audioPathMeta = const VerificationMeta(
    'audioPath',
  );
  @override
  late final GeneratedColumn<String> audioPath = GeneratedColumn<String>(
    'audio_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _languageMeta = const VerificationMeta(
    'language',
  );
  @override
  late final GeneratedColumn<String> language = GeneratedColumn<String>(
    'language',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('en'),
  );
  static const VerificationMeta _regionMeta = const VerificationMeta('region');
  @override
  late final GeneratedColumn<String> region = GeneratedColumn<String>(
    'region',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
    'tags',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('personal'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _isFavoriteMeta = const VerificationMeta(
    'isFavorite',
  );
  @override
  late final GeneratedColumn<bool> isFavorite = GeneratedColumn<bool>(
    'is_favorite',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_favorite" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _syncStatusMeta = const VerificationMeta(
    'syncStatus',
  );
  @override
  late final GeneratedColumn<String> syncStatus = GeneratedColumn<String>(
    'sync_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _retryCountMeta = const VerificationMeta(
    'retryCount',
  );
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
    'retry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastSyncAttemptMeta = const VerificationMeta(
    'lastSyncAttempt',
  );
  @override
  late final GeneratedColumn<DateTime> lastSyncAttempt =
      GeneratedColumn<DateTime>(
        'last_sync_attempt',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    localId,
    serverId,
    title,
    description,
    mediaUri,
    category,
    relationship,
    personName,
    location,
    eventDate,
    imagePath,
    audioPath,
    language,
    region,
    tags,
    source,
    createdAt,
    updatedAt,
    isFavorite,
    isArchived,
    syncStatus,
    retryCount,
    lastSyncAttempt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'memories';
  @override
  VerificationContext validateIntegrity(
    Insertable<Memory> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    } else if (isInserting) {
      context.missing(_localIdMeta);
    }
    if (data.containsKey('server_id')) {
      context.handle(
        _serverIdMeta,
        serverId.isAcceptableOrUnknown(data['server_id']!, _serverIdMeta),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('media_uri')) {
      context.handle(
        _mediaUriMeta,
        mediaUri.isAcceptableOrUnknown(data['media_uri']!, _mediaUriMeta),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('relationship')) {
      context.handle(
        _relationshipMeta,
        relationship.isAcceptableOrUnknown(
          data['relationship']!,
          _relationshipMeta,
        ),
      );
    }
    if (data.containsKey('person_name')) {
      context.handle(
        _personNameMeta,
        personName.isAcceptableOrUnknown(data['person_name']!, _personNameMeta),
      );
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    }
    if (data.containsKey('event_date')) {
      context.handle(
        _eventDateMeta,
        eventDate.isAcceptableOrUnknown(data['event_date']!, _eventDateMeta),
      );
    }
    if (data.containsKey('image_path')) {
      context.handle(
        _imagePathMeta,
        imagePath.isAcceptableOrUnknown(data['image_path']!, _imagePathMeta),
      );
    }
    if (data.containsKey('audio_path')) {
      context.handle(
        _audioPathMeta,
        audioPath.isAcceptableOrUnknown(data['audio_path']!, _audioPathMeta),
      );
    }
    if (data.containsKey('language')) {
      context.handle(
        _languageMeta,
        language.isAcceptableOrUnknown(data['language']!, _languageMeta),
      );
    }
    if (data.containsKey('region')) {
      context.handle(
        _regionMeta,
        region.isAcceptableOrUnknown(data['region']!, _regionMeta),
      );
    }
    if (data.containsKey('tags')) {
      context.handle(
        _tagsMeta,
        tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('is_favorite')) {
      context.handle(
        _isFavoriteMeta,
        isFavorite.isAcceptableOrUnknown(data['is_favorite']!, _isFavoriteMeta),
      );
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    if (data.containsKey('sync_status')) {
      context.handle(
        _syncStatusMeta,
        syncStatus.isAcceptableOrUnknown(data['sync_status']!, _syncStatusMeta),
      );
    }
    if (data.containsKey('retry_count')) {
      context.handle(
        _retryCountMeta,
        retryCount.isAcceptableOrUnknown(data['retry_count']!, _retryCountMeta),
      );
    }
    if (data.containsKey('last_sync_attempt')) {
      context.handle(
        _lastSyncAttemptMeta,
        lastSyncAttempt.isAcceptableOrUnknown(
          data['last_sync_attempt']!,
          _lastSyncAttemptMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  Memory map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Memory(
      localId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_id'],
      )!,
      serverId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_id'],
      ),
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      mediaUri: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_uri'],
      ),
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      relationship: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}relationship'],
      ),
      personName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}person_name'],
      ),
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      ),
      eventDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}event_date'],
      ),
      imagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}image_path'],
      ),
      audioPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audio_path'],
      ),
      language: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}language'],
      )!,
      region: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}region'],
      ),
      tags: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tags'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      isFavorite: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_favorite'],
      )!,
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
      syncStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sync_status'],
      )!,
      retryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retry_count'],
      )!,
      lastSyncAttempt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_sync_attempt'],
      ),
    );
  }

  @override
  $MemoriesTable createAlias(String alias) {
    return $MemoriesTable(attachedDatabase, alias);
  }
}

class Memory extends DataClass implements Insertable<Memory> {
  final String localId;
  final String? serverId;
  final String title;
  final String description;
  final String? mediaUri;
  final String category;
  final String? relationship;
  final String? personName;
  final String? location;
  final DateTime? eventDate;
  final String? imagePath;
  final String? audioPath;
  final String language;
  final String? region;
  final String? tags;
  final String source;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isFavorite;
  final bool isArchived;
  final String syncStatus;
  final int retryCount;
  final DateTime? lastSyncAttempt;
  const Memory({
    required this.localId,
    this.serverId,
    required this.title,
    required this.description,
    this.mediaUri,
    required this.category,
    this.relationship,
    this.personName,
    this.location,
    this.eventDate,
    this.imagePath,
    this.audioPath,
    required this.language,
    this.region,
    this.tags,
    required this.source,
    required this.createdAt,
    required this.updatedAt,
    required this.isFavorite,
    required this.isArchived,
    required this.syncStatus,
    required this.retryCount,
    this.lastSyncAttempt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<String>(localId);
    if (!nullToAbsent || serverId != null) {
      map['server_id'] = Variable<String>(serverId);
    }
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    if (!nullToAbsent || mediaUri != null) {
      map['media_uri'] = Variable<String>(mediaUri);
    }
    map['category'] = Variable<String>(category);
    if (!nullToAbsent || relationship != null) {
      map['relationship'] = Variable<String>(relationship);
    }
    if (!nullToAbsent || personName != null) {
      map['person_name'] = Variable<String>(personName);
    }
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    if (!nullToAbsent || eventDate != null) {
      map['event_date'] = Variable<DateTime>(eventDate);
    }
    if (!nullToAbsent || imagePath != null) {
      map['image_path'] = Variable<String>(imagePath);
    }
    if (!nullToAbsent || audioPath != null) {
      map['audio_path'] = Variable<String>(audioPath);
    }
    map['language'] = Variable<String>(language);
    if (!nullToAbsent || region != null) {
      map['region'] = Variable<String>(region);
    }
    if (!nullToAbsent || tags != null) {
      map['tags'] = Variable<String>(tags);
    }
    map['source'] = Variable<String>(source);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    map['is_favorite'] = Variable<bool>(isFavorite);
    map['is_archived'] = Variable<bool>(isArchived);
    map['sync_status'] = Variable<String>(syncStatus);
    map['retry_count'] = Variable<int>(retryCount);
    if (!nullToAbsent || lastSyncAttempt != null) {
      map['last_sync_attempt'] = Variable<DateTime>(lastSyncAttempt);
    }
    return map;
  }

  MemoriesCompanion toCompanion(bool nullToAbsent) {
    return MemoriesCompanion(
      localId: Value(localId),
      serverId: serverId == null && nullToAbsent
          ? const Value.absent()
          : Value(serverId),
      title: Value(title),
      description: Value(description),
      mediaUri: mediaUri == null && nullToAbsent
          ? const Value.absent()
          : Value(mediaUri),
      category: Value(category),
      relationship: relationship == null && nullToAbsent
          ? const Value.absent()
          : Value(relationship),
      personName: personName == null && nullToAbsent
          ? const Value.absent()
          : Value(personName),
      location: location == null && nullToAbsent
          ? const Value.absent()
          : Value(location),
      eventDate: eventDate == null && nullToAbsent
          ? const Value.absent()
          : Value(eventDate),
      imagePath: imagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(imagePath),
      audioPath: audioPath == null && nullToAbsent
          ? const Value.absent()
          : Value(audioPath),
      language: Value(language),
      region: region == null && nullToAbsent
          ? const Value.absent()
          : Value(region),
      tags: tags == null && nullToAbsent ? const Value.absent() : Value(tags),
      source: Value(source),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      isFavorite: Value(isFavorite),
      isArchived: Value(isArchived),
      syncStatus: Value(syncStatus),
      retryCount: Value(retryCount),
      lastSyncAttempt: lastSyncAttempt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastSyncAttempt),
    );
  }

  factory Memory.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Memory(
      localId: serializer.fromJson<String>(json['localId']),
      serverId: serializer.fromJson<String?>(json['serverId']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      mediaUri: serializer.fromJson<String?>(json['mediaUri']),
      category: serializer.fromJson<String>(json['category']),
      relationship: serializer.fromJson<String?>(json['relationship']),
      personName: serializer.fromJson<String?>(json['personName']),
      location: serializer.fromJson<String?>(json['location']),
      eventDate: serializer.fromJson<DateTime?>(json['eventDate']),
      imagePath: serializer.fromJson<String?>(json['imagePath']),
      audioPath: serializer.fromJson<String?>(json['audioPath']),
      language: serializer.fromJson<String>(json['language']),
      region: serializer.fromJson<String?>(json['region']),
      tags: serializer.fromJson<String?>(json['tags']),
      source: serializer.fromJson<String>(json['source']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      isFavorite: serializer.fromJson<bool>(json['isFavorite']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      syncStatus: serializer.fromJson<String>(json['syncStatus']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      lastSyncAttempt: serializer.fromJson<DateTime?>(json['lastSyncAttempt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<String>(localId),
      'serverId': serializer.toJson<String?>(serverId),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'mediaUri': serializer.toJson<String?>(mediaUri),
      'category': serializer.toJson<String>(category),
      'relationship': serializer.toJson<String?>(relationship),
      'personName': serializer.toJson<String?>(personName),
      'location': serializer.toJson<String?>(location),
      'eventDate': serializer.toJson<DateTime?>(eventDate),
      'imagePath': serializer.toJson<String?>(imagePath),
      'audioPath': serializer.toJson<String?>(audioPath),
      'language': serializer.toJson<String>(language),
      'region': serializer.toJson<String?>(region),
      'tags': serializer.toJson<String?>(tags),
      'source': serializer.toJson<String>(source),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'isFavorite': serializer.toJson<bool>(isFavorite),
      'isArchived': serializer.toJson<bool>(isArchived),
      'syncStatus': serializer.toJson<String>(syncStatus),
      'retryCount': serializer.toJson<int>(retryCount),
      'lastSyncAttempt': serializer.toJson<DateTime?>(lastSyncAttempt),
    };
  }

  Memory copyWith({
    String? localId,
    Value<String?> serverId = const Value.absent(),
    String? title,
    String? description,
    Value<String?> mediaUri = const Value.absent(),
    String? category,
    Value<String?> relationship = const Value.absent(),
    Value<String?> personName = const Value.absent(),
    Value<String?> location = const Value.absent(),
    Value<DateTime?> eventDate = const Value.absent(),
    Value<String?> imagePath = const Value.absent(),
    Value<String?> audioPath = const Value.absent(),
    String? language,
    Value<String?> region = const Value.absent(),
    Value<String?> tags = const Value.absent(),
    String? source,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isFavorite,
    bool? isArchived,
    String? syncStatus,
    int? retryCount,
    Value<DateTime?> lastSyncAttempt = const Value.absent(),
  }) => Memory(
    localId: localId ?? this.localId,
    serverId: serverId.present ? serverId.value : this.serverId,
    title: title ?? this.title,
    description: description ?? this.description,
    mediaUri: mediaUri.present ? mediaUri.value : this.mediaUri,
    category: category ?? this.category,
    relationship: relationship.present ? relationship.value : this.relationship,
    personName: personName.present ? personName.value : this.personName,
    location: location.present ? location.value : this.location,
    eventDate: eventDate.present ? eventDate.value : this.eventDate,
    imagePath: imagePath.present ? imagePath.value : this.imagePath,
    audioPath: audioPath.present ? audioPath.value : this.audioPath,
    language: language ?? this.language,
    region: region.present ? region.value : this.region,
    tags: tags.present ? tags.value : this.tags,
    source: source ?? this.source,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    isFavorite: isFavorite ?? this.isFavorite,
    isArchived: isArchived ?? this.isArchived,
    syncStatus: syncStatus ?? this.syncStatus,
    retryCount: retryCount ?? this.retryCount,
    lastSyncAttempt: lastSyncAttempt.present
        ? lastSyncAttempt.value
        : this.lastSyncAttempt,
  );
  Memory copyWithCompanion(MemoriesCompanion data) {
    return Memory(
      localId: data.localId.present ? data.localId.value : this.localId,
      serverId: data.serverId.present ? data.serverId.value : this.serverId,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      mediaUri: data.mediaUri.present ? data.mediaUri.value : this.mediaUri,
      category: data.category.present ? data.category.value : this.category,
      relationship: data.relationship.present
          ? data.relationship.value
          : this.relationship,
      personName: data.personName.present
          ? data.personName.value
          : this.personName,
      location: data.location.present ? data.location.value : this.location,
      eventDate: data.eventDate.present ? data.eventDate.value : this.eventDate,
      imagePath: data.imagePath.present ? data.imagePath.value : this.imagePath,
      audioPath: data.audioPath.present ? data.audioPath.value : this.audioPath,
      language: data.language.present ? data.language.value : this.language,
      region: data.region.present ? data.region.value : this.region,
      tags: data.tags.present ? data.tags.value : this.tags,
      source: data.source.present ? data.source.value : this.source,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      isFavorite: data.isFavorite.present
          ? data.isFavorite.value
          : this.isFavorite,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
      syncStatus: data.syncStatus.present
          ? data.syncStatus.value
          : this.syncStatus,
      retryCount: data.retryCount.present
          ? data.retryCount.value
          : this.retryCount,
      lastSyncAttempt: data.lastSyncAttempt.present
          ? data.lastSyncAttempt.value
          : this.lastSyncAttempt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Memory(')
          ..write('localId: $localId, ')
          ..write('serverId: $serverId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('mediaUri: $mediaUri, ')
          ..write('category: $category, ')
          ..write('relationship: $relationship, ')
          ..write('personName: $personName, ')
          ..write('location: $location, ')
          ..write('eventDate: $eventDate, ')
          ..write('imagePath: $imagePath, ')
          ..write('audioPath: $audioPath, ')
          ..write('language: $language, ')
          ..write('region: $region, ')
          ..write('tags: $tags, ')
          ..write('source: $source, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('isArchived: $isArchived, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastSyncAttempt: $lastSyncAttempt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hashAll([
    localId,
    serverId,
    title,
    description,
    mediaUri,
    category,
    relationship,
    personName,
    location,
    eventDate,
    imagePath,
    audioPath,
    language,
    region,
    tags,
    source,
    createdAt,
    updatedAt,
    isFavorite,
    isArchived,
    syncStatus,
    retryCount,
    lastSyncAttempt,
  ]);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Memory &&
          other.localId == this.localId &&
          other.serverId == this.serverId &&
          other.title == this.title &&
          other.description == this.description &&
          other.mediaUri == this.mediaUri &&
          other.category == this.category &&
          other.relationship == this.relationship &&
          other.personName == this.personName &&
          other.location == this.location &&
          other.eventDate == this.eventDate &&
          other.imagePath == this.imagePath &&
          other.audioPath == this.audioPath &&
          other.language == this.language &&
          other.region == this.region &&
          other.tags == this.tags &&
          other.source == this.source &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.isFavorite == this.isFavorite &&
          other.isArchived == this.isArchived &&
          other.syncStatus == this.syncStatus &&
          other.retryCount == this.retryCount &&
          other.lastSyncAttempt == this.lastSyncAttempt);
}

class MemoriesCompanion extends UpdateCompanion<Memory> {
  final Value<String> localId;
  final Value<String?> serverId;
  final Value<String> title;
  final Value<String> description;
  final Value<String?> mediaUri;
  final Value<String> category;
  final Value<String?> relationship;
  final Value<String?> personName;
  final Value<String?> location;
  final Value<DateTime?> eventDate;
  final Value<String?> imagePath;
  final Value<String?> audioPath;
  final Value<String> language;
  final Value<String?> region;
  final Value<String?> tags;
  final Value<String> source;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<bool> isFavorite;
  final Value<bool> isArchived;
  final Value<String> syncStatus;
  final Value<int> retryCount;
  final Value<DateTime?> lastSyncAttempt;
  final Value<int> rowid;
  const MemoriesCompanion({
    this.localId = const Value.absent(),
    this.serverId = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.mediaUri = const Value.absent(),
    this.category = const Value.absent(),
    this.relationship = const Value.absent(),
    this.personName = const Value.absent(),
    this.location = const Value.absent(),
    this.eventDate = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.audioPath = const Value.absent(),
    this.language = const Value.absent(),
    this.region = const Value.absent(),
    this.tags = const Value.absent(),
    this.source = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastSyncAttempt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MemoriesCompanion.insert({
    required String localId,
    this.serverId = const Value.absent(),
    required String title,
    required String description,
    this.mediaUri = const Value.absent(),
    this.category = const Value.absent(),
    this.relationship = const Value.absent(),
    this.personName = const Value.absent(),
    this.location = const Value.absent(),
    this.eventDate = const Value.absent(),
    this.imagePath = const Value.absent(),
    this.audioPath = const Value.absent(),
    this.language = const Value.absent(),
    this.region = const Value.absent(),
    this.tags = const Value.absent(),
    this.source = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.isFavorite = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.syncStatus = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastSyncAttempt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : localId = Value(localId),
       title = Value(title),
       description = Value(description);
  static Insertable<Memory> custom({
    Expression<String>? localId,
    Expression<String>? serverId,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? mediaUri,
    Expression<String>? category,
    Expression<String>? relationship,
    Expression<String>? personName,
    Expression<String>? location,
    Expression<DateTime>? eventDate,
    Expression<String>? imagePath,
    Expression<String>? audioPath,
    Expression<String>? language,
    Expression<String>? region,
    Expression<String>? tags,
    Expression<String>? source,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<bool>? isFavorite,
    Expression<bool>? isArchived,
    Expression<String>? syncStatus,
    Expression<int>? retryCount,
    Expression<DateTime>? lastSyncAttempt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (serverId != null) 'server_id': serverId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (mediaUri != null) 'media_uri': mediaUri,
      if (category != null) 'category': category,
      if (relationship != null) 'relationship': relationship,
      if (personName != null) 'person_name': personName,
      if (location != null) 'location': location,
      if (eventDate != null) 'event_date': eventDate,
      if (imagePath != null) 'image_path': imagePath,
      if (audioPath != null) 'audio_path': audioPath,
      if (language != null) 'language': language,
      if (region != null) 'region': region,
      if (tags != null) 'tags': tags,
      if (source != null) 'source': source,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (isFavorite != null) 'is_favorite': isFavorite,
      if (isArchived != null) 'is_archived': isArchived,
      if (syncStatus != null) 'sync_status': syncStatus,
      if (retryCount != null) 'retry_count': retryCount,
      if (lastSyncAttempt != null) 'last_sync_attempt': lastSyncAttempt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MemoriesCompanion copyWith({
    Value<String>? localId,
    Value<String?>? serverId,
    Value<String>? title,
    Value<String>? description,
    Value<String?>? mediaUri,
    Value<String>? category,
    Value<String?>? relationship,
    Value<String?>? personName,
    Value<String?>? location,
    Value<DateTime?>? eventDate,
    Value<String?>? imagePath,
    Value<String?>? audioPath,
    Value<String>? language,
    Value<String?>? region,
    Value<String?>? tags,
    Value<String>? source,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<bool>? isFavorite,
    Value<bool>? isArchived,
    Value<String>? syncStatus,
    Value<int>? retryCount,
    Value<DateTime?>? lastSyncAttempt,
    Value<int>? rowid,
  }) {
    return MemoriesCompanion(
      localId: localId ?? this.localId,
      serverId: serverId ?? this.serverId,
      title: title ?? this.title,
      description: description ?? this.description,
      mediaUri: mediaUri ?? this.mediaUri,
      category: category ?? this.category,
      relationship: relationship ?? this.relationship,
      personName: personName ?? this.personName,
      location: location ?? this.location,
      eventDate: eventDate ?? this.eventDate,
      imagePath: imagePath ?? this.imagePath,
      audioPath: audioPath ?? this.audioPath,
      language: language ?? this.language,
      region: region ?? this.region,
      tags: tags ?? this.tags,
      source: source ?? this.source,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isFavorite: isFavorite ?? this.isFavorite,
      isArchived: isArchived ?? this.isArchived,
      syncStatus: syncStatus ?? this.syncStatus,
      retryCount: retryCount ?? this.retryCount,
      lastSyncAttempt: lastSyncAttempt ?? this.lastSyncAttempt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<String>(localId.value);
    }
    if (serverId.present) {
      map['server_id'] = Variable<String>(serverId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (mediaUri.present) {
      map['media_uri'] = Variable<String>(mediaUri.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (relationship.present) {
      map['relationship'] = Variable<String>(relationship.value);
    }
    if (personName.present) {
      map['person_name'] = Variable<String>(personName.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (eventDate.present) {
      map['event_date'] = Variable<DateTime>(eventDate.value);
    }
    if (imagePath.present) {
      map['image_path'] = Variable<String>(imagePath.value);
    }
    if (audioPath.present) {
      map['audio_path'] = Variable<String>(audioPath.value);
    }
    if (language.present) {
      map['language'] = Variable<String>(language.value);
    }
    if (region.present) {
      map['region'] = Variable<String>(region.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (isFavorite.present) {
      map['is_favorite'] = Variable<bool>(isFavorite.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (syncStatus.present) {
      map['sync_status'] = Variable<String>(syncStatus.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (lastSyncAttempt.present) {
      map['last_sync_attempt'] = Variable<DateTime>(lastSyncAttempt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MemoriesCompanion(')
          ..write('localId: $localId, ')
          ..write('serverId: $serverId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('mediaUri: $mediaUri, ')
          ..write('category: $category, ')
          ..write('relationship: $relationship, ')
          ..write('personName: $personName, ')
          ..write('location: $location, ')
          ..write('eventDate: $eventDate, ')
          ..write('imagePath: $imagePath, ')
          ..write('audioPath: $audioPath, ')
          ..write('language: $language, ')
          ..write('region: $region, ')
          ..write('tags: $tags, ')
          ..write('source: $source, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('isFavorite: $isFavorite, ')
          ..write('isArchived: $isArchived, ')
          ..write('syncStatus: $syncStatus, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastSyncAttempt: $lastSyncAttempt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncQueueTable extends SyncQueue
    with TableInfo<$SyncQueueTable, SyncQueueData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncQueueTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _localIdMeta = const VerificationMeta(
    'localId',
  );
  @override
  late final GeneratedColumn<String> localId = GeneratedColumn<String>(
    'local_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityTypeMeta = const VerificationMeta(
    'entityType',
  );
  @override
  late final GeneratedColumn<String> entityType = GeneratedColumn<String>(
    'entity_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entityIdMeta = const VerificationMeta(
    'entityId',
  );
  @override
  late final GeneratedColumn<String> entityId = GeneratedColumn<String>(
    'entity_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _operationMeta = const VerificationMeta(
    'operation',
  );
  @override
  late final GeneratedColumn<String> operation = GeneratedColumn<String>(
    'operation',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _retryCountMeta = const VerificationMeta(
    'retryCount',
  );
  @override
  late final GeneratedColumn<int> retryCount = GeneratedColumn<int>(
    'retry_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastAttemptAtMeta = const VerificationMeta(
    'lastAttemptAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastAttemptAt =
      GeneratedColumn<DateTime>(
        'last_attempt_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    localId,
    entityType,
    entityId,
    operation,
    status,
    retryCount,
    lastAttemptAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_queue';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncQueueData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('local_id')) {
      context.handle(
        _localIdMeta,
        localId.isAcceptableOrUnknown(data['local_id']!, _localIdMeta),
      );
    } else if (isInserting) {
      context.missing(_localIdMeta);
    }
    if (data.containsKey('entity_type')) {
      context.handle(
        _entityTypeMeta,
        entityType.isAcceptableOrUnknown(data['entity_type']!, _entityTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_entityTypeMeta);
    }
    if (data.containsKey('entity_id')) {
      context.handle(
        _entityIdMeta,
        entityId.isAcceptableOrUnknown(data['entity_id']!, _entityIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entityIdMeta);
    }
    if (data.containsKey('operation')) {
      context.handle(
        _operationMeta,
        operation.isAcceptableOrUnknown(data['operation']!, _operationMeta),
      );
    } else if (isInserting) {
      context.missing(_operationMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('retry_count')) {
      context.handle(
        _retryCountMeta,
        retryCount.isAcceptableOrUnknown(data['retry_count']!, _retryCountMeta),
      );
    }
    if (data.containsKey('last_attempt_at')) {
      context.handle(
        _lastAttemptAtMeta,
        lastAttemptAt.isAcceptableOrUnknown(
          data['last_attempt_at']!,
          _lastAttemptAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {localId};
  @override
  SyncQueueData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncQueueData(
      localId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_id'],
      )!,
      entityType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_type'],
      )!,
      entityId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entity_id'],
      )!,
      operation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}operation'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      retryCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retry_count'],
      )!,
      lastAttemptAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_attempt_at'],
      ),
    );
  }

  @override
  $SyncQueueTable createAlias(String alias) {
    return $SyncQueueTable(attachedDatabase, alias);
  }
}

class SyncQueueData extends DataClass implements Insertable<SyncQueueData> {
  final String localId;
  final String entityType;
  final String entityId;
  final String operation;
  final String status;
  final int retryCount;
  final DateTime? lastAttemptAt;
  const SyncQueueData({
    required this.localId,
    required this.entityType,
    required this.entityId,
    required this.operation,
    required this.status,
    required this.retryCount,
    this.lastAttemptAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['local_id'] = Variable<String>(localId);
    map['entity_type'] = Variable<String>(entityType);
    map['entity_id'] = Variable<String>(entityId);
    map['operation'] = Variable<String>(operation);
    map['status'] = Variable<String>(status);
    map['retry_count'] = Variable<int>(retryCount);
    if (!nullToAbsent || lastAttemptAt != null) {
      map['last_attempt_at'] = Variable<DateTime>(lastAttemptAt);
    }
    return map;
  }

  SyncQueueCompanion toCompanion(bool nullToAbsent) {
    return SyncQueueCompanion(
      localId: Value(localId),
      entityType: Value(entityType),
      entityId: Value(entityId),
      operation: Value(operation),
      status: Value(status),
      retryCount: Value(retryCount),
      lastAttemptAt: lastAttemptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAttemptAt),
    );
  }

  factory SyncQueueData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncQueueData(
      localId: serializer.fromJson<String>(json['localId']),
      entityType: serializer.fromJson<String>(json['entityType']),
      entityId: serializer.fromJson<String>(json['entityId']),
      operation: serializer.fromJson<String>(json['operation']),
      status: serializer.fromJson<String>(json['status']),
      retryCount: serializer.fromJson<int>(json['retryCount']),
      lastAttemptAt: serializer.fromJson<DateTime?>(json['lastAttemptAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'localId': serializer.toJson<String>(localId),
      'entityType': serializer.toJson<String>(entityType),
      'entityId': serializer.toJson<String>(entityId),
      'operation': serializer.toJson<String>(operation),
      'status': serializer.toJson<String>(status),
      'retryCount': serializer.toJson<int>(retryCount),
      'lastAttemptAt': serializer.toJson<DateTime?>(lastAttemptAt),
    };
  }

  SyncQueueData copyWith({
    String? localId,
    String? entityType,
    String? entityId,
    String? operation,
    String? status,
    int? retryCount,
    Value<DateTime?> lastAttemptAt = const Value.absent(),
  }) => SyncQueueData(
    localId: localId ?? this.localId,
    entityType: entityType ?? this.entityType,
    entityId: entityId ?? this.entityId,
    operation: operation ?? this.operation,
    status: status ?? this.status,
    retryCount: retryCount ?? this.retryCount,
    lastAttemptAt: lastAttemptAt.present
        ? lastAttemptAt.value
        : this.lastAttemptAt,
  );
  SyncQueueData copyWithCompanion(SyncQueueCompanion data) {
    return SyncQueueData(
      localId: data.localId.present ? data.localId.value : this.localId,
      entityType: data.entityType.present
          ? data.entityType.value
          : this.entityType,
      entityId: data.entityId.present ? data.entityId.value : this.entityId,
      operation: data.operation.present ? data.operation.value : this.operation,
      status: data.status.present ? data.status.value : this.status,
      retryCount: data.retryCount.present
          ? data.retryCount.value
          : this.retryCount,
      lastAttemptAt: data.lastAttemptAt.present
          ? data.lastAttemptAt.value
          : this.lastAttemptAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueData(')
          ..write('localId: $localId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('status: $status, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastAttemptAt: $lastAttemptAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    localId,
    entityType,
    entityId,
    operation,
    status,
    retryCount,
    lastAttemptAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncQueueData &&
          other.localId == this.localId &&
          other.entityType == this.entityType &&
          other.entityId == this.entityId &&
          other.operation == this.operation &&
          other.status == this.status &&
          other.retryCount == this.retryCount &&
          other.lastAttemptAt == this.lastAttemptAt);
}

class SyncQueueCompanion extends UpdateCompanion<SyncQueueData> {
  final Value<String> localId;
  final Value<String> entityType;
  final Value<String> entityId;
  final Value<String> operation;
  final Value<String> status;
  final Value<int> retryCount;
  final Value<DateTime?> lastAttemptAt;
  final Value<int> rowid;
  const SyncQueueCompanion({
    this.localId = const Value.absent(),
    this.entityType = const Value.absent(),
    this.entityId = const Value.absent(),
    this.operation = const Value.absent(),
    this.status = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastAttemptAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncQueueCompanion.insert({
    required String localId,
    required String entityType,
    required String entityId,
    required String operation,
    this.status = const Value.absent(),
    this.retryCount = const Value.absent(),
    this.lastAttemptAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : localId = Value(localId),
       entityType = Value(entityType),
       entityId = Value(entityId),
       operation = Value(operation);
  static Insertable<SyncQueueData> custom({
    Expression<String>? localId,
    Expression<String>? entityType,
    Expression<String>? entityId,
    Expression<String>? operation,
    Expression<String>? status,
    Expression<int>? retryCount,
    Expression<DateTime>? lastAttemptAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (localId != null) 'local_id': localId,
      if (entityType != null) 'entity_type': entityType,
      if (entityId != null) 'entity_id': entityId,
      if (operation != null) 'operation': operation,
      if (status != null) 'status': status,
      if (retryCount != null) 'retry_count': retryCount,
      if (lastAttemptAt != null) 'last_attempt_at': lastAttemptAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncQueueCompanion copyWith({
    Value<String>? localId,
    Value<String>? entityType,
    Value<String>? entityId,
    Value<String>? operation,
    Value<String>? status,
    Value<int>? retryCount,
    Value<DateTime?>? lastAttemptAt,
    Value<int>? rowid,
  }) {
    return SyncQueueCompanion(
      localId: localId ?? this.localId,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      operation: operation ?? this.operation,
      status: status ?? this.status,
      retryCount: retryCount ?? this.retryCount,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (localId.present) {
      map['local_id'] = Variable<String>(localId.value);
    }
    if (entityType.present) {
      map['entity_type'] = Variable<String>(entityType.value);
    }
    if (entityId.present) {
      map['entity_id'] = Variable<String>(entityId.value);
    }
    if (operation.present) {
      map['operation'] = Variable<String>(operation.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (retryCount.present) {
      map['retry_count'] = Variable<int>(retryCount.value);
    }
    if (lastAttemptAt.present) {
      map['last_attempt_at'] = Variable<DateTime>(lastAttemptAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncQueueCompanion(')
          ..write('localId: $localId, ')
          ..write('entityType: $entityType, ')
          ..write('entityId: $entityId, ')
          ..write('operation: $operation, ')
          ..write('status: $status, ')
          ..write('retryCount: $retryCount, ')
          ..write('lastAttemptAt: $lastAttemptAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $GameSessionsTable gameSessions = $GameSessionsTable(this);
  late final $RemindersTable reminders = $RemindersTable(this);
  late final $ReminderEventsTable reminderEvents = $ReminderEventsTable(this);
  late final $RoutinesTable routines = $RoutinesTable(this);
  late final $MemoriesTable memories = $MemoriesTable(this);
  late final $SyncQueueTable syncQueue = $SyncQueueTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    gameSessions,
    reminders,
    reminderEvents,
    routines,
    memories,
    syncQueue,
  ];
}

typedef $$GameSessionsTableCreateCompanionBuilder =
    GameSessionsCompanion Function({
      required String localId,
      Value<String?> serverId,
      required String gameType,
      required int score,
      required double accuracy,
      required int mistakes,
      required double responseTimeMs,
      required int difficulty,
      required int hintCount,
      required DateTime startedAt,
      required DateTime completedAt,
      Value<String> syncStatus,
      Value<int> rowid,
    });
typedef $$GameSessionsTableUpdateCompanionBuilder =
    GameSessionsCompanion Function({
      Value<String> localId,
      Value<String?> serverId,
      Value<String> gameType,
      Value<int> score,
      Value<double> accuracy,
      Value<int> mistakes,
      Value<double> responseTimeMs,
      Value<int> difficulty,
      Value<int> hintCount,
      Value<DateTime> startedAt,
      Value<DateTime> completedAt,
      Value<String> syncStatus,
      Value<int> rowid,
    });

class $$GameSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $GameSessionsTable> {
  $$GameSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get gameType => $composableBuilder(
    column: $table.gameType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get accuracy => $composableBuilder(
    column: $table.accuracy,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mistakes => $composableBuilder(
    column: $table.mistakes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get responseTimeMs => $composableBuilder(
    column: $table.responseTimeMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get hintCount => $composableBuilder(
    column: $table.hintCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GameSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $GameSessionsTable> {
  $$GameSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get gameType => $composableBuilder(
    column: $table.gameType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get accuracy => $composableBuilder(
    column: $table.accuracy,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mistakes => $composableBuilder(
    column: $table.mistakes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get responseTimeMs => $composableBuilder(
    column: $table.responseTimeMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get hintCount => $composableBuilder(
    column: $table.hintCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GameSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $GameSessionsTable> {
  $$GameSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get gameType =>
      $composableBuilder(column: $table.gameType, builder: (column) => column);

  GeneratedColumn<int> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  GeneratedColumn<double> get accuracy =>
      $composableBuilder(column: $table.accuracy, builder: (column) => column);

  GeneratedColumn<int> get mistakes =>
      $composableBuilder(column: $table.mistakes, builder: (column) => column);

  GeneratedColumn<double> get responseTimeMs => $composableBuilder(
    column: $table.responseTimeMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => column,
  );

  GeneratedColumn<int> get hintCount =>
      $composableBuilder(column: $table.hintCount, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );
}

class $$GameSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GameSessionsTable,
          GameSession,
          $$GameSessionsTableFilterComposer,
          $$GameSessionsTableOrderingComposer,
          $$GameSessionsTableAnnotationComposer,
          $$GameSessionsTableCreateCompanionBuilder,
          $$GameSessionsTableUpdateCompanionBuilder,
          (
            GameSession,
            BaseReferences<_$AppDatabase, $GameSessionsTable, GameSession>,
          ),
          GameSession,
          PrefetchHooks Function()
        > {
  $$GameSessionsTableTableManager(_$AppDatabase db, $GameSessionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GameSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GameSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GameSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> localId = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                Value<String> gameType = const Value.absent(),
                Value<int> score = const Value.absent(),
                Value<double> accuracy = const Value.absent(),
                Value<int> mistakes = const Value.absent(),
                Value<double> responseTimeMs = const Value.absent(),
                Value<int> difficulty = const Value.absent(),
                Value<int> hintCount = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime> completedAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GameSessionsCompanion(
                localId: localId,
                serverId: serverId,
                gameType: gameType,
                score: score,
                accuracy: accuracy,
                mistakes: mistakes,
                responseTimeMs: responseTimeMs,
                difficulty: difficulty,
                hintCount: hintCount,
                startedAt: startedAt,
                completedAt: completedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String localId,
                Value<String?> serverId = const Value.absent(),
                required String gameType,
                required int score,
                required double accuracy,
                required int mistakes,
                required double responseTimeMs,
                required int difficulty,
                required int hintCount,
                required DateTime startedAt,
                required DateTime completedAt,
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GameSessionsCompanion.insert(
                localId: localId,
                serverId: serverId,
                gameType: gameType,
                score: score,
                accuracy: accuracy,
                mistakes: mistakes,
                responseTimeMs: responseTimeMs,
                difficulty: difficulty,
                hintCount: hintCount,
                startedAt: startedAt,
                completedAt: completedAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$GameSessionsTable, GameSession>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $GameSessionsTable,
                    GameSession
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GameSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GameSessionsTable,
      GameSession,
      $$GameSessionsTableFilterComposer,
      $$GameSessionsTableOrderingComposer,
      $$GameSessionsTableAnnotationComposer,
      $$GameSessionsTableCreateCompanionBuilder,
      $$GameSessionsTableUpdateCompanionBuilder,
      (
        GameSession,
        BaseReferences<_$AppDatabase, $GameSessionsTable, GameSession>,
      ),
      GameSession,
      PrefetchHooks Function()
    >;
typedef $$RemindersTableCreateCompanionBuilder = RemindersCompanion Function({
  required String localId,
  Value<String?> serverId,
  required String title,
  required String reminderType,
  required String scheduledTime,
  Value<bool> enabled,
  Value<String> syncStatus,
  Value<int> rowid,
});
typedef $$RemindersTableUpdateCompanionBuilder = RemindersCompanion Function({
  Value<String> localId,
  Value<String?> serverId,
  Value<String> title,
  Value<String> reminderType,
  Value<String> scheduledTime,
  Value<bool> enabled,
  Value<String> syncStatus,
  Value<int> rowid,
});

class $$RemindersTableFilterComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reminderType => $composableBuilder(
    column: $table.reminderType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scheduledTime => $composableBuilder(
    column: $table.scheduledTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RemindersTableOrderingComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reminderType => $composableBuilder(
    column: $table.reminderType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scheduledTime => $composableBuilder(
    column: $table.scheduledTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RemindersTableAnnotationComposer
    extends Composer<_$AppDatabase, $RemindersTable> {
  $$RemindersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get reminderType => $composableBuilder(
    column: $table.reminderType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get scheduledTime => $composableBuilder(
    column: $table.scheduledTime,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );
}

class $$RemindersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RemindersTable,
          Reminder,
          $$RemindersTableFilterComposer,
          $$RemindersTableOrderingComposer,
          $$RemindersTableAnnotationComposer,
          $$RemindersTableCreateCompanionBuilder,
          $$RemindersTableUpdateCompanionBuilder,
          (Reminder, BaseReferences<_$AppDatabase, $RemindersTable, Reminder>),
          Reminder,
          PrefetchHooks Function()
        > {
  $$RemindersTableTableManager(_$AppDatabase db, $RemindersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RemindersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RemindersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RemindersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> localId = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> reminderType = const Value.absent(),
                Value<String> scheduledTime = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RemindersCompanion(
                localId: localId,
                serverId: serverId,
                title: title,
                reminderType: reminderType,
                scheduledTime: scheduledTime,
                enabled: enabled,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String localId,
                Value<String?> serverId = const Value.absent(),
                required String title,
                required String reminderType,
                required String scheduledTime,
                Value<bool> enabled = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RemindersCompanion.insert(
                localId: localId,
                serverId: serverId,
                title: title,
                reminderType: reminderType,
                scheduledTime: scheduledTime,
                enabled: enabled,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RemindersTable, Reminder>(table),
                  BaseReferences<_$AppDatabase, $RemindersTable, Reminder>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RemindersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RemindersTable,
      Reminder,
      $$RemindersTableFilterComposer,
      $$RemindersTableOrderingComposer,
      $$RemindersTableAnnotationComposer,
      $$RemindersTableCreateCompanionBuilder,
      $$RemindersTableUpdateCompanionBuilder,
      (Reminder, BaseReferences<_$AppDatabase, $RemindersTable, Reminder>),
      Reminder,
      PrefetchHooks Function()
    >;
typedef $$ReminderEventsTableCreateCompanionBuilder =
    ReminderEventsCompanion Function({
      required String localId,
      required String reminderId,
      required String eventType,
      required DateTime occurredAt,
      Value<String> syncStatus,
      Value<int> rowid,
    });
typedef $$ReminderEventsTableUpdateCompanionBuilder =
    ReminderEventsCompanion Function({
      Value<String> localId,
      Value<String> reminderId,
      Value<String> eventType,
      Value<DateTime> occurredAt,
      Value<String> syncStatus,
      Value<int> rowid,
    });

class $$ReminderEventsTableFilterComposer
    extends Composer<_$AppDatabase, $ReminderEventsTable> {
  $$ReminderEventsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reminderId => $composableBuilder(
    column: $table.reminderId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReminderEventsTableOrderingComposer
    extends Composer<_$AppDatabase, $ReminderEventsTable> {
  $$ReminderEventsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reminderId => $composableBuilder(
    column: $table.reminderId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReminderEventsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReminderEventsTable> {
  $$ReminderEventsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<String> get reminderId => $composableBuilder(
    column: $table.reminderId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );
}

class $$ReminderEventsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReminderEventsTable,
          ReminderEvent,
          $$ReminderEventsTableFilterComposer,
          $$ReminderEventsTableOrderingComposer,
          $$ReminderEventsTableAnnotationComposer,
          $$ReminderEventsTableCreateCompanionBuilder,
          $$ReminderEventsTableUpdateCompanionBuilder,
          (
            ReminderEvent,
            BaseReferences<_$AppDatabase, $ReminderEventsTable, ReminderEvent>,
          ),
          ReminderEvent,
          PrefetchHooks Function()
        > {
  $$ReminderEventsTableTableManager(
    _$AppDatabase db,
    $ReminderEventsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReminderEventsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReminderEventsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReminderEventsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> localId = const Value.absent(),
                Value<String> reminderId = const Value.absent(),
                Value<String> eventType = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReminderEventsCompanion(
                localId: localId,
                reminderId: reminderId,
                eventType: eventType,
                occurredAt: occurredAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String localId,
                required String reminderId,
                required String eventType,
                required DateTime occurredAt,
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReminderEventsCompanion.insert(
                localId: localId,
                reminderId: reminderId,
                eventType: eventType,
                occurredAt: occurredAt,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ReminderEventsTable, ReminderEvent>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ReminderEventsTable,
                    ReminderEvent
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReminderEventsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReminderEventsTable,
      ReminderEvent,
      $$ReminderEventsTableFilterComposer,
      $$ReminderEventsTableOrderingComposer,
      $$ReminderEventsTableAnnotationComposer,
      $$ReminderEventsTableCreateCompanionBuilder,
      $$ReminderEventsTableUpdateCompanionBuilder,
      (
        ReminderEvent,
        BaseReferences<_$AppDatabase, $ReminderEventsTable, ReminderEvent>,
      ),
      ReminderEvent,
      PrefetchHooks Function()
    >;
typedef $$RoutinesTableCreateCompanionBuilder = RoutinesCompanion Function({
  required String localId,
  Value<String?> serverId,
  required String title,
  required String stepsJson,
  required String preferredTime,
  Value<bool> enabled,
  Value<String> syncStatus,
  Value<int> rowid,
});
typedef $$RoutinesTableUpdateCompanionBuilder = RoutinesCompanion Function({
  Value<String> localId,
  Value<String?> serverId,
  Value<String> title,
  Value<String> stepsJson,
  Value<String> preferredTime,
  Value<bool> enabled,
  Value<String> syncStatus,
  Value<int> rowid,
});

class $$RoutinesTableFilterComposer
    extends Composer<_$AppDatabase, $RoutinesTable> {
  $$RoutinesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stepsJson => $composableBuilder(
    column: $table.stepsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get preferredTime => $composableBuilder(
    column: $table.preferredTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );
}

class $$RoutinesTableOrderingComposer
    extends Composer<_$AppDatabase, $RoutinesTable> {
  $$RoutinesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stepsJson => $composableBuilder(
    column: $table.stepsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get preferredTime => $composableBuilder(
    column: $table.preferredTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$RoutinesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RoutinesTable> {
  $$RoutinesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get stepsJson =>
      $composableBuilder(column: $table.stepsJson, builder: (column) => column);

  GeneratedColumn<String> get preferredTime => $composableBuilder(
    column: $table.preferredTime,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );
}

class $$RoutinesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RoutinesTable,
          Routine,
          $$RoutinesTableFilterComposer,
          $$RoutinesTableOrderingComposer,
          $$RoutinesTableAnnotationComposer,
          $$RoutinesTableCreateCompanionBuilder,
          $$RoutinesTableUpdateCompanionBuilder,
          (Routine, BaseReferences<_$AppDatabase, $RoutinesTable, Routine>),
          Routine,
          PrefetchHooks Function()
        > {
  $$RoutinesTableTableManager(_$AppDatabase db, $RoutinesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RoutinesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RoutinesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RoutinesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> localId = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> stepsJson = const Value.absent(),
                Value<String> preferredTime = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RoutinesCompanion(
                localId: localId,
                serverId: serverId,
                title: title,
                stepsJson: stepsJson,
                preferredTime: preferredTime,
                enabled: enabled,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String localId,
                Value<String?> serverId = const Value.absent(),
                required String title,
                required String stepsJson,
                required String preferredTime,
                Value<bool> enabled = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => RoutinesCompanion.insert(
                localId: localId,
                serverId: serverId,
                title: title,
                stepsJson: stepsJson,
                preferredTime: preferredTime,
                enabled: enabled,
                syncStatus: syncStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RoutinesTable, Routine>(table),
                  BaseReferences<_$AppDatabase, $RoutinesTable, Routine>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$RoutinesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RoutinesTable,
      Routine,
      $$RoutinesTableFilterComposer,
      $$RoutinesTableOrderingComposer,
      $$RoutinesTableAnnotationComposer,
      $$RoutinesTableCreateCompanionBuilder,
      $$RoutinesTableUpdateCompanionBuilder,
      (Routine, BaseReferences<_$AppDatabase, $RoutinesTable, Routine>),
      Routine,
      PrefetchHooks Function()
    >;
typedef $$MemoriesTableCreateCompanionBuilder = MemoriesCompanion Function({
  required String localId,
  Value<String?> serverId,
  required String title,
  required String description,
  Value<String?> mediaUri,
  Value<String> category,
  Value<String?> relationship,
  Value<String?> personName,
  Value<String?> location,
  Value<DateTime?> eventDate,
  Value<String?> imagePath,
  Value<String?> audioPath,
  Value<String> language,
  Value<String?> region,
  Value<String?> tags,
  Value<String> source,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isFavorite,
  Value<bool> isArchived,
  Value<String> syncStatus,
  Value<int> retryCount,
  Value<DateTime?> lastSyncAttempt,
  Value<int> rowid,
});
typedef $$MemoriesTableUpdateCompanionBuilder = MemoriesCompanion Function({
  Value<String> localId,
  Value<String?> serverId,
  Value<String> title,
  Value<String> description,
  Value<String?> mediaUri,
  Value<String> category,
  Value<String?> relationship,
  Value<String?> personName,
  Value<String?> location,
  Value<DateTime?> eventDate,
  Value<String?> imagePath,
  Value<String?> audioPath,
  Value<String> language,
  Value<String?> region,
  Value<String?> tags,
  Value<String> source,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<bool> isFavorite,
  Value<bool> isArchived,
  Value<String> syncStatus,
  Value<int> retryCount,
  Value<DateTime?> lastSyncAttempt,
  Value<int> rowid,
});

class $$MemoriesTableFilterComposer
    extends Composer<_$AppDatabase, $MemoriesTable> {
  $$MemoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mediaUri => $composableBuilder(
    column: $table.mediaUri,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get relationship => $composableBuilder(
    column: $table.relationship,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get personName => $composableBuilder(
    column: $table.personName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get eventDate => $composableBuilder(
    column: $table.eventDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get audioPath => $composableBuilder(
    column: $table.audioPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get region => $composableBuilder(
    column: $table.region,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastSyncAttempt => $composableBuilder(
    column: $table.lastSyncAttempt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MemoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $MemoriesTable> {
  $$MemoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverId => $composableBuilder(
    column: $table.serverId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mediaUri => $composableBuilder(
    column: $table.mediaUri,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get relationship => $composableBuilder(
    column: $table.relationship,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get personName => $composableBuilder(
    column: $table.personName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get eventDate => $composableBuilder(
    column: $table.eventDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get imagePath => $composableBuilder(
    column: $table.imagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get audioPath => $composableBuilder(
    column: $table.audioPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get language => $composableBuilder(
    column: $table.language,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get region => $composableBuilder(
    column: $table.region,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastSyncAttempt => $composableBuilder(
    column: $table.lastSyncAttempt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MemoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MemoriesTable> {
  $$MemoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<String> get serverId =>
      $composableBuilder(column: $table.serverId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mediaUri =>
      $composableBuilder(column: $table.mediaUri, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get relationship => $composableBuilder(
    column: $table.relationship,
    builder: (column) => column,
  );

  GeneratedColumn<String> get personName => $composableBuilder(
    column: $table.personName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<DateTime> get eventDate =>
      $composableBuilder(column: $table.eventDate, builder: (column) => column);

  GeneratedColumn<String> get imagePath =>
      $composableBuilder(column: $table.imagePath, builder: (column) => column);

  GeneratedColumn<String> get audioPath =>
      $composableBuilder(column: $table.audioPath, builder: (column) => column);

  GeneratedColumn<String> get language =>
      $composableBuilder(column: $table.language, builder: (column) => column);

  GeneratedColumn<String> get region =>
      $composableBuilder(column: $table.region, builder: (column) => column);

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<bool> get isFavorite => $composableBuilder(
    column: $table.isFavorite,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );

  GeneratedColumn<String> get syncStatus => $composableBuilder(
    column: $table.syncStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastSyncAttempt => $composableBuilder(
    column: $table.lastSyncAttempt,
    builder: (column) => column,
  );
}

class $$MemoriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MemoriesTable,
          Memory,
          $$MemoriesTableFilterComposer,
          $$MemoriesTableOrderingComposer,
          $$MemoriesTableAnnotationComposer,
          $$MemoriesTableCreateCompanionBuilder,
          $$MemoriesTableUpdateCompanionBuilder,
          (Memory, BaseReferences<_$AppDatabase, $MemoriesTable, Memory>),
          Memory,
          PrefetchHooks Function()
        > {
  $$MemoriesTableTableManager(_$AppDatabase db, $MemoriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MemoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MemoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MemoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> localId = const Value.absent(),
                Value<String?> serverId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String?> mediaUri = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String?> relationship = const Value.absent(),
                Value<String?> personName = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<DateTime?> eventDate = const Value.absent(),
                Value<String?> imagePath = const Value.absent(),
                Value<String?> audioPath = const Value.absent(),
                Value<String> language = const Value.absent(),
                Value<String?> region = const Value.absent(),
                Value<String?> tags = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<DateTime?> lastSyncAttempt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MemoriesCompanion(
                localId: localId,
                serverId: serverId,
                title: title,
                description: description,
                mediaUri: mediaUri,
                category: category,
                relationship: relationship,
                personName: personName,
                location: location,
                eventDate: eventDate,
                imagePath: imagePath,
                audioPath: audioPath,
                language: language,
                region: region,
                tags: tags,
                source: source,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isFavorite: isFavorite,
                isArchived: isArchived,
                syncStatus: syncStatus,
                retryCount: retryCount,
                lastSyncAttempt: lastSyncAttempt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String localId,
                Value<String?> serverId = const Value.absent(),
                required String title,
                required String description,
                Value<String?> mediaUri = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String?> relationship = const Value.absent(),
                Value<String?> personName = const Value.absent(),
                Value<String?> location = const Value.absent(),
                Value<DateTime?> eventDate = const Value.absent(),
                Value<String?> imagePath = const Value.absent(),
                Value<String?> audioPath = const Value.absent(),
                Value<String> language = const Value.absent(),
                Value<String?> region = const Value.absent(),
                Value<String?> tags = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<bool> isFavorite = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<String> syncStatus = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<DateTime?> lastSyncAttempt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MemoriesCompanion.insert(
                localId: localId,
                serverId: serverId,
                title: title,
                description: description,
                mediaUri: mediaUri,
                category: category,
                relationship: relationship,
                personName: personName,
                location: location,
                eventDate: eventDate,
                imagePath: imagePath,
                audioPath: audioPath,
                language: language,
                region: region,
                tags: tags,
                source: source,
                createdAt: createdAt,
                updatedAt: updatedAt,
                isFavorite: isFavorite,
                isArchived: isArchived,
                syncStatus: syncStatus,
                retryCount: retryCount,
                lastSyncAttempt: lastSyncAttempt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MemoriesTable, Memory>(table),
                  BaseReferences<_$AppDatabase, $MemoriesTable, Memory>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MemoriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MemoriesTable,
      Memory,
      $$MemoriesTableFilterComposer,
      $$MemoriesTableOrderingComposer,
      $$MemoriesTableAnnotationComposer,
      $$MemoriesTableCreateCompanionBuilder,
      $$MemoriesTableUpdateCompanionBuilder,
      (Memory, BaseReferences<_$AppDatabase, $MemoriesTable, Memory>),
      Memory,
      PrefetchHooks Function()
    >;
typedef $$SyncQueueTableCreateCompanionBuilder = SyncQueueCompanion Function({
  required String localId,
  required String entityType,
  required String entityId,
  required String operation,
  Value<String> status,
  Value<int> retryCount,
  Value<DateTime?> lastAttemptAt,
  Value<int> rowid,
});
typedef $$SyncQueueTableUpdateCompanionBuilder = SyncQueueCompanion Function({
  Value<String> localId,
  Value<String> entityType,
  Value<String> entityId,
  Value<String> operation,
  Value<String> status,
  Value<int> retryCount,
  Value<DateTime?> lastAttemptAt,
  Value<int> rowid,
});

class $$SyncQueueTableFilterComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncQueueTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get localId => $composableBuilder(
    column: $table.localId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entityId => $composableBuilder(
    column: $table.entityId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get operation => $composableBuilder(
    column: $table.operation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncQueueTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncQueueTable> {
  $$SyncQueueTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get localId =>
      $composableBuilder(column: $table.localId, builder: (column) => column);

  GeneratedColumn<String> get entityType => $composableBuilder(
    column: $table.entityType,
    builder: (column) => column,
  );

  GeneratedColumn<String> get entityId =>
      $composableBuilder(column: $table.entityId, builder: (column) => column);

  GeneratedColumn<String> get operation =>
      $composableBuilder(column: $table.operation, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get retryCount => $composableBuilder(
    column: $table.retryCount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => column,
  );
}

class $$SyncQueueTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncQueueTable,
          SyncQueueData,
          $$SyncQueueTableFilterComposer,
          $$SyncQueueTableOrderingComposer,
          $$SyncQueueTableAnnotationComposer,
          $$SyncQueueTableCreateCompanionBuilder,
          $$SyncQueueTableUpdateCompanionBuilder,
          (
            SyncQueueData,
            BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueData>,
          ),
          SyncQueueData,
          PrefetchHooks Function()
        > {
  $$SyncQueueTableTableManager(_$AppDatabase db, $SyncQueueTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncQueueTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncQueueTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncQueueTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> localId = const Value.absent(),
                Value<String> entityType = const Value.absent(),
                Value<String> entityId = const Value.absent(),
                Value<String> operation = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<DateTime?> lastAttemptAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncQueueCompanion(
                localId: localId,
                entityType: entityType,
                entityId: entityId,
                operation: operation,
                status: status,
                retryCount: retryCount,
                lastAttemptAt: lastAttemptAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String localId,
                required String entityType,
                required String entityId,
                required String operation,
                Value<String> status = const Value.absent(),
                Value<int> retryCount = const Value.absent(),
                Value<DateTime?> lastAttemptAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncQueueCompanion.insert(
                localId: localId,
                entityType: entityType,
                entityId: entityId,
                operation: operation,
                status: status,
                retryCount: retryCount,
                lastAttemptAt: lastAttemptAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SyncQueueTable, SyncQueueData>(table),
                  BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueData>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncQueueTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncQueueTable,
      SyncQueueData,
      $$SyncQueueTableFilterComposer,
      $$SyncQueueTableOrderingComposer,
      $$SyncQueueTableAnnotationComposer,
      $$SyncQueueTableCreateCompanionBuilder,
      $$SyncQueueTableUpdateCompanionBuilder,
      (
        SyncQueueData,
        BaseReferences<_$AppDatabase, $SyncQueueTable, SyncQueueData>,
      ),
      SyncQueueData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$GameSessionsTableTableManager get gameSessions =>
      $$GameSessionsTableTableManager(_db, _db.gameSessions);
  $$RemindersTableTableManager get reminders =>
      $$RemindersTableTableManager(_db, _db.reminders);
  $$ReminderEventsTableTableManager get reminderEvents =>
      $$ReminderEventsTableTableManager(_db, _db.reminderEvents);
  $$RoutinesTableTableManager get routines =>
      $$RoutinesTableTableManager(_db, _db.routines);
  $$MemoriesTableTableManager get memories =>
      $$MemoriesTableTableManager(_db, _db.memories);
  $$SyncQueueTableTableManager get syncQueue =>
      $$SyncQueueTableTableManager(_db, _db.syncQueue);
}
