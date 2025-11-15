import 'package:flutter/material.dart';

/// 半透明蒙版加载组件
class Loading extends StatelessWidget {
  const Loading({
    super.key,
    this.backgroundColor = Colors.black54,
    // this.loadingColor = Colors.white,
    this.message,
    this.messageStyle,
  });

  /// 蒙版背景颜色
  final Color backgroundColor;

  /// 加载指示器颜色
  // final Color loadingColor;

  /// 加载提示文字
  final String? message;

  /// 加载提示文字样式
  final TextStyle? messageStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: backgroundColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 加载指示器
            Container(
              padding: const EdgeInsets.all(20),
              // decoration: BoxDecoration(
              //   color: theme.cardColor.withAlpha(128),
              //   borderRadius: BorderRadius.circular(16),
              //   boxShadow: [
              //     BoxShadow(
              //       color: Colors.black.withValues(alpha: 0.2),
              //       blurRadius: 8,
              //       offset: const Offset(0, 4),
              //     ),
              //   ],
              // ),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  // 加载动画
                  SizedBox(
                    width: 64,
                    height: 64,
                    child: CircularProgressIndicator(
                      strokeWidth: 5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.primaryColor,
                      ),
                    ),
                  ),
                  if (message != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      message!,
                      style:
                          messageStyle ??
                          TextStyle(
                            color: theme.colorScheme.primary,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 通用页面加载器
/// 可以在任何页面中使用，显示半透明蒙版加载效果
class PageLoader extends StatelessWidget {
  const PageLoader({
    super.key,
    this.isLoading = false,
    this.loadingMessage,
    this.child,
  });

  /// 是否显示加载状态
  final bool isLoading;

  /// 加载提示文字
  final String? loadingMessage;

  /// 子组件（原页面内容）
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 原页面内容
        if (child != null) child!,

        // 加载蒙版（仅在加载时显示）
        if (isLoading) Loading(message: loadingMessage),
      ],
    );
  }
}
