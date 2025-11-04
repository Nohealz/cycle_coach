import 'package:freezed_annotation/freezed_annotation.dart';
import 'converters.dart';

part 'cue_card.freezed.dart';
part 'cue_card.g.dart';

@freezed
abstract class CueCard with _$CueCard {
  const factory CueCard({
    required String id,
    required String title,
    String? description,
    @DurationSecondsConverter() required Duration offset,
    @DurationSecondsConverter() Duration? duration,
  }) = _CueCard;

  factory CueCard.fromJson(Map<String, dynamic> json) => _$CueCardFromJson(json);
}
