import 'package:drag_and_drop_lists/mobile_pagination/base_pagiantion.dart';
import 'package:drag_and_drop_lists/mobile_pagination/debouncer.dart';
import 'package:flutter/material.dart';

class MobilePaginationBuilder extends StatefulWidget {
  final BasePagination? pagination;
  final bool isLoading;
  final double? height;
  final bool? showShadow;
  final void Function(int)? onPageChange;
  final dynamic Function(BuildContext, bool isLastPage, int itemCount)
      listWidget;
  final int itemCount;

  const MobilePaginationBuilder({
    super.key,
    this.showShadow,
    required this.pagination,
    required this.isLoading,
    this.onPageChange,
    this.height,
    required this.listWidget,
    required int? itemCount,
  }) : itemCount = itemCount ?? 0;

  @override
  State<MobilePaginationBuilder> createState() =>
      _MobilePaginationBuilderState();
}

class _MobilePaginationBuilderState extends State<MobilePaginationBuilder> {
  final debouncer = Debouncer(delay: const Duration(milliseconds: 500));

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading && widget.pagination == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final isLastPage = widget.pagination?.isLastPage ?? false;

    return SizedBox(
      height: widget.height,
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo.metrics.pixels == scrollInfo.metrics.maxScrollExtent) {
            if (!widget.isLoading && !isLastPage) {
              debouncer.debounce(() {
                widget.onPageChange
                    ?.call((widget.pagination?.currentPage ?? 0) + 1);
              });
            }
          }
          return false;
        },
        child: widget.showShadow ?? true
            ? ShaderMask(
                shaderCallback: (Rect rect) {
                  return const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.white,
                      Colors.transparent,
                      Colors.transparent,
                      Colors.white
                    ],
                    stops: [0.0, 0.1, 0.9, 1.0],
                  ).createShader(rect);
                },
                blendMode: BlendMode.dstOut,
                child: widget.listWidget(
                  context,
                  isLastPage,
                  widget.itemCount + (isLastPage ? 0 : 1),
                ),
              )
            : widget.listWidget(
                context,
                isLastPage,
                widget.itemCount + (isLastPage ? 0 : 1),
              ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
