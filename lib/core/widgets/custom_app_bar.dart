import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final bool showLogo;
  final Widget? leading;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final VoidCallback? onMenuPressed;

  const CustomAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.showLogo = false,
    this.leading,
    this.actions,
    this.bottom,
    this.onMenuPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.white,
      elevation: 0,
      centerTitle: true,
      leading: onMenuPressed != null
          ? IconButton(
              icon: const Icon(Icons.menu, color: AppColors.textDarkPurple),
              onPressed: onMenuPressed,
            )
          : leading,
      title:
          titleWidget ??
          (showLogo
              ? Image.asset(
                  'assets/images/logo.png',
                  height: 24,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Text(
                    title ?? "Citymind",
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                )
              : Text(
                  title ?? "",
                  style: const TextStyle(
                    color: AppColors.textOnWhite,
                    fontWeight: FontWeight.bold,
                  ),
                )),
      actions: actions ?? [const SizedBox(width: 48)],
      bottom: bottom,
    );
  }

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0.0));
}
