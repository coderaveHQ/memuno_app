import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:memuno_app/src/app/widgets/app_avatar.dart';
import 'package:memuno_app/src/features/profile/application/providers/current_user_profile_provider.dart';
import 'package:memuno_app/src/features/profile/domain/entities/user_profile_entity.dart';

class ProfileAvatar extends ConsumerWidget {
  final void Function()? onPressed;
  final double size;

  const ProfileAvatar({super.key, this.onPressed, this.size = 36.0});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<UserProfileEntity> profileState = ref.watch(
      currentUserProfileProvider,
    );
    return AppAvatar(
      onPressed: onPressed,
      name: profileState.asData?.value.name,
      isLoading: profileState.isLoading,
      size: size,
    );
  }
}
