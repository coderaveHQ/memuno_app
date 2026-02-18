import 'package:memuno_app/src/app/widgets/m/m_colors.dart';
import 'package:skeletonizer/skeletonizer.dart';

class MTheme {
  static const double borderRadius = 8.0;

  static final SkeletonizerConfigData _baseSkeletonizerData =
      SkeletonizerConfigData(enableSwitchAnimation: true);

  static SkeletonizerConfigData sekeltonizerLightData = _baseSkeletonizerData
      .copyWith(
        containersColor: MColors.gray300,
        effect: ShimmerEffect(
          baseColor: MColors.gray200,
          highlightColor: MColors.gray300,
        ),
      );

  static SkeletonizerConfigData sekeltonizerDarkData = _baseSkeletonizerData
      .copyWith(
        containersColor: MColors.gray700,
        effect: ShimmerEffect(
          baseColor: MColors.gray800,
          highlightColor: MColors.gray700,
        ),
      );
}
