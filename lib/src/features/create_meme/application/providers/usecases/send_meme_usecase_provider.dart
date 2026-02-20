import 'package:memuno_app/src/features/create_meme/application/providers/meme_editor_validator_provider.dart';
import 'package:memuno_app/src/features/create_meme/application/providers/meme_send_repository_provider.dart';
import 'package:memuno_app/src/features/create_meme/domain/repositories/meme_send_repository.dart';
import 'package:memuno_app/src/features/create_meme/domain/usecases/send_meme_usecase.dart';
import 'package:memuno_app/src/features/create_meme/domain/validators/meme_editor_validator.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'send_meme_usecase_provider.g.dart';

/// Provides the [SendMemeUsecase] usecase.
@riverpod
SendMemeUsecase sendMemeUsecase(Ref ref) {
  final MemeSendRepository repository = ref.watch(memeSendRepositoryProvider);
  final MemeEditorValidator validator = ref.watch(memeEditorValidatorProvider);

  return SendMemeUsecase(repository: repository, validator: validator);
}
