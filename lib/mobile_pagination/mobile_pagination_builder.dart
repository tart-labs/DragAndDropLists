import 'package:drag_and_drop_lists/mobile_pagination/base_pagiantion.dart';
import 'package:drag_and_drop_lists/mobile_pagination/debouncer.dart';
import 'package:flutter/material.dart';

class MobilePagination extends StatefulWidget {
  final ScrollController scrollController;
  final PipelineBasePagination? pagination;
  final bool isLoading;
  final bool showLoader;

  final double? height;
  final void Function(int)? onPageChange;
  final Widget Function(BuildContext, bool isLastPage, int itemCount)
      listWidget;
  final int itemCount;

  const MobilePagination({
    super.key,
    required this.scrollController,
    required this.pagination,
    required this.isLoading,
    this.showLoader = true,
    this.onPageChange,
    this.height,
    required this.listWidget,
    required int? itemCount,
  }) : itemCount = itemCount ?? 0;

  @override
  State<MobilePagination> createState() => _PaginationBuilderState();
}

class _PaginationBuilderState extends State<MobilePagination> {
  final debouncer = Debouncer();

  @override
  void initState() {
    super.initState();
    widget.scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final maxScroll = widget.scrollController.position.maxScrollExtent;
    final currentScroll = widget.scrollController.position.pixels;

    if (maxScroll - currentScroll <= 200) {
      if (!widget.isLoading && !(widget.pagination?.isLastPage ?? true)) {
        debouncer.debounce(() {
          widget.onPageChange?.call((widget.pagination?.currentPage ?? 0) + 1);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.showLoader) {
      return Container();
    }
    if (widget.isLoading && widget.pagination == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final isLastPage = widget.pagination?.isLastPage ?? false;

    return SizedBox(
      height: widget.height,
      child: widget.listWidget(
        context,
        isLastPage,
        widget.itemCount + (isLastPage ? 0 : 1),
      ),
    );
  }

  @override
  void dispose() {
    widget.scrollController.removeListener(_onScroll);
    super.dispose();
  }
}
