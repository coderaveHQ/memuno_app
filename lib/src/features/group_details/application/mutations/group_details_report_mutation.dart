import 'package:hooks_riverpod/experimental/mutation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'group_details_report_mutation.g.dart';

/// Mutation: report one group from group-details info page.
@riverpod
Mutation<void> groupDetailsReportMutation(Ref ref, String groupId) {
  return Mutation<void>(label: 'group_details_report:$groupId');
}
