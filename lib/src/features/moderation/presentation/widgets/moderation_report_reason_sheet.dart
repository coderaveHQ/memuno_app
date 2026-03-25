import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:memuno_app/l10n/app_localizations.dart';
import 'package:memuno_app/src/app/extensions/build_context_x.dart';
import 'package:memuno_app/src/app/widgets/m/m_button.dart';
import 'package:memuno_app/src/app/widgets/m/m_colors.dart';
import 'package:memuno_app/src/app/widgets/m/m_gap.dart';
import 'package:memuno_app/src/app/widgets/m/m_icon_button.dart';
import 'package:memuno_app/src/app/widgets/m/m_list_tile.dart';
import 'package:memuno_app/src/app/widgets/m/m_radio_indicator.dart';
import 'package:memuno_app/src/app/widgets/m/m_spacing.dart';
import 'package:memuno_app/src/app/widgets/m/m_text.dart';
import 'package:memuno_app/src/features/moderation/domain/entities/ugc_report_reason.dart';
import 'package:smooth_sheets/smooth_sheets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Loads report reasons from Postgres enum metadata.
Future<List<UgcReportReason>> listModerationReportReasons(
  SupabaseClient supabaseClient,
) async {
  final Object? payload = await supabaseClient.rpc<Object?>(
    'ugc_report_reason_list',
  );
  if (payload is! List) {
    throw FormatException(
      'Expected `ugc_report_reason_list` to return a JSON array payload.',
    );
  }

  return payload
      .map((dynamic row) {
        if (row is! Map) {
          throw const FormatException(
            'Expected one object row in `ugc_report_reason_list` response.',
          );
        }
        final Map<Object?, Object?> map = Map<Object?, Object?>.from(row);
        final Object? rawReason = map['reason'];
        if (rawReason is! String || rawReason.isEmpty) {
          throw const FormatException(
            'Expected non-empty `reason` in `ugc_report_reason_list` response row.',
          );
        }
        return UgcReportReason.fromDatabaseValue(rawReason);
      })
      .toList(growable: false);
}

/// Loads report reasons and opens one shared report-reason picker sheet.
Future<UgcReportReason?> showModerationReportReasonPicker(
  BuildContext context, {
  required SupabaseClient supabaseClient,
  required String title,
}) async {
  final List<UgcReportReason> reasons = await listModerationReportReasons(
    supabaseClient,
  );
  if (!context.mounted) {
    return null;
  }
  if (reasons.isEmpty) {
    throw StateError(
      'No moderation report reasons are configured in the database.',
    );
  }

  return showModerationReportReasonSheet(
    context,
    title: title,
    reasons: reasons,
  );
}

/// Opens a shared report-reason selector with yellow trailing selection UI.
Future<UgcReportReason?> showModerationReportReasonSheet(
  BuildContext context, {
  required String title,
  required List<UgcReportReason> reasons,
}) async {
  return showModalSheet<UgcReportReason>(
    context: context,
    useRootNavigator: true,
    swipeDismissible: true,
    viewportPadding: EdgeInsets.only(
      top: MediaQuery.viewPaddingOf(context).top,
    ),
    builder: (BuildContext _) {
      return _ModerationReportReasonSheet(title: title, reasons: reasons);
    },
  );
}

class _ModerationReportReasonSheet extends StatefulWidget {
  const _ModerationReportReasonSheet({
    required this.title,
    required this.reasons,
  });

  final String title;
  final List<UgcReportReason> reasons;

  @override
  State<_ModerationReportReasonSheet> createState() =>
      _ModerationReportReasonSheetState();
}

class _ModerationReportReasonSheetState
    extends State<_ModerationReportReasonSheet> {
  UgcReportReason? _selectedReason;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    final bool hasSelection = _selectedReason != null;

    return Sheet(
      initialOffset: const SheetOffset(1),
      snapGrid: const SheetSnapGrid.single(snap: SheetOffset(1)),
      decoration: const MaterialSheetDecoration(
        size: SheetSize.stretch,
        color: MColors.gray900,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
        clipBehavior: Clip.antiAlias,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                top: MSpacing.md,
                bottom: MSpacing.md,
                left: context.leftPadding + MSpacing.md,
                right: context.rightPadding + MSpacing.md,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: MText.h4(
                      text: widget.title,
                      style: const TextStyle(color: MColors.gray100),
                    ),
                  ),
                  const MGap.md(),
                  MIconButton.secondary(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: LucideIcons.x,
                    dimension: kToolbarHeight - 4.0,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: widget.reasons.length,
                itemBuilder: (BuildContext context, int index) {
                  final UgcReportReason reason = widget.reasons[index];
                  final bool isSelected = _selectedReason == reason;

                  return MListTile(
                    onPressed: () {
                      setState(() {
                        _selectedReason = reason;
                      });
                    },
                    title: reason.localizedLabel(l10n),
                    trailing: MRadioIndicator(isSelected: isSelected),
                    padding: EdgeInsets.only(
                      top: MSpacing.md,
                      left: context.leftPadding + MSpacing.md,
                      right: context.rightPadding + MSpacing.md,
                      bottom: MSpacing.md,
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: EdgeInsets.only(
                top: MSpacing.md,
                bottom: context.bottomPadding + MSpacing.md,
                left: context.leftPadding + MSpacing.md,
                right: context.rightPadding + MSpacing.md,
              ),
              child: MButton.primary(
                onPressed: !hasSelection
                    ? null
                    : () {
                        Navigator.of(context).pop(_selectedReason);
                      },
                isEnabled: hasSelection,
                title: l10n.moderationReportSubmitButton,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
