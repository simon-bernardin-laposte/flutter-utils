import 'package:flutter/material.dart';

class AdaptativeWidget extends StatelessWidget {
  final Widget? child;
  final bool? primary;
  final bool canExpand;
  final EdgeInsets? padding;
  final LayoutWidgetBuilder? builder;
  final ScrollController? controller;
  final ScrollPhysics? physics;

  const AdaptativeWidget(
      {Key? key,
      this.child,
      this.primary,
      this.canExpand = false,
      this.padding,
      this.controller,
      this.physics})
      : builder = null,
        super(key: key);

  const AdaptativeWidget.builder(
      {Key? key,
      this.builder,
      this.primary,
      this.canExpand = false,
      this.padding,
      this.controller,
      this.physics})
      : child = null,
        super(key: key);

  @override
  Widget build(BuildContext context) => LayoutBuilder(
          builder: (BuildContext context, BoxConstraints viewportConstraints) {
        final result = child ?? builder!(context, viewportConstraints);
        return SingleChildScrollView(
            primary: primary,
            controller: controller,
            physics: physics,
            padding: padding,
            child: ConstrainedBox(
                constraints:
                    BoxConstraints(minHeight: viewportConstraints.maxHeight),
                child: canExpand ? IntrinsicHeight(child: result) : result));
      });
}
