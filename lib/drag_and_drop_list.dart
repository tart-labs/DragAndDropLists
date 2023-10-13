import 'package:drag_and_drop_lists/drag_and_drop_builder_parameters.dart';
import 'package:drag_and_drop_lists/drag_and_drop_item.dart';
import 'package:drag_and_drop_lists/drag_and_drop_item_target.dart';
import 'package:drag_and_drop_lists/drag_and_drop_item_wrapper.dart';
import 'package:drag_and_drop_lists/drag_and_drop_list_interface.dart';
import 'package:drag_and_drop_lists/mobile_pagination/base_pagiantion.dart';
import 'package:drag_and_drop_lists/mobile_pagination/mobile_pagination_builder.dart';
import 'package:flutter/material.dart';

class DragAndDropList implements DragAndDropListInterface {
  /// The widget that is displayed at the top of the list.
  final Widget? header;

  /// The widget that is displayed at the bottom of the list.
  final Widget? footer;

  /// The widget that is displayed to the left of the list.
  final Widget? leftSide;

  /// The widget that is displayed to the right of the list.
  final Widget? rightSide;

  /// The widget to be displayed when a list is empty.
  /// If this is not null, it will override that set in [DragAndDropLists.contentsWhenEmpty].
  final Widget? contentsWhenEmpty;

  /// The widget to be displayed as the last element in the list that will accept
  /// a dragged item.
  final Widget? lastTarget;

  /// The decoration displayed around a list.
  /// If this is not null, it will override that set in [DragAndDropLists.listDecoration].
  final Decoration? decoration;

  /// The vertical alignment of the contents in this list.
  /// If this is not null, it will override that set in [DragAndDropLists.verticalAlignment].
  final CrossAxisAlignment verticalAlignment;

  /// The horizontal alignment of the contents in this list.
  /// If this is not null, it will override that set in [DragAndDropLists.horizontalAlignment].
  final MainAxisAlignment horizontalAlignment;

  /// The child elements that will be contained in this list.
  /// It is possible to not provide any children when an empty list is desired.
  final List<DragAndDropItem> children;

  /// Whether or not this item can be dragged.
  /// Set to true if it can be reordered.
  /// Set to false if it must remain fixed.
  final bool canDrag;
  final Widget? emptyState;
  final PipelineBasePagination? pagination;
  final bool isPaginationLoading;
  final ScrollController? controller;
  final Function(int)? onPageChange;

  ///set board height
  final double? boardHeight;
  DragAndDropList({
    required this.children,
    this.header,
    this.footer,
    this.leftSide,
    this.emptyState,
    this.rightSide,
    this.contentsWhenEmpty,
    this.lastTarget,
    this.decoration,
    this.boardHeight,
    this.horizontalAlignment = MainAxisAlignment.start,
    this.verticalAlignment = CrossAxisAlignment.start,
    this.canDrag = true,
    this.pagination,
    this.isPaginationLoading = false,
    this.controller,
    this.onPageChange,
  });

  @override
  Widget generateWidget(DragAndDropBuilderParameters params) {
    var contents = <Widget>[];
    if (header != null) {
      contents.add(Flexible(child: header!));
    }
    Widget intrinsicHeight = SingleChildScrollView(
      child: SizedBox(
        height: boardHeight,
        child: Row(
          mainAxisAlignment: horizontalAlignment,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: _generateDragAndDropListInnerContents(params),
        ),
      ),
    );
    if (params.axis == Axis.horizontal) {
      intrinsicHeight = Container(
        width: params.listWidth,
        child: intrinsicHeight,
      );
    }
    if (params.listInnerDecoration != null) {
      intrinsicHeight = Container(
        decoration: params.listInnerDecoration,
        child: intrinsicHeight,
      );
    }
    contents.add(intrinsicHeight);

    if (footer != null) {
      contents.add(Flexible(child: footer!));
    }

    return Container(
      width: params.axis == Axis.vertical
          ? double.infinity
          : params.listWidth - params.listPadding!.horizontal,
      decoration: decoration ?? params.listDecoration,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: verticalAlignment,
        children: contents,
      ),
    );
  }

  List<Widget> _generateDragAndDropListInnerContents(
      DragAndDropBuilderParameters parameters) {
    var contents = <Widget>[];
    if (leftSide != null) {
      contents.add(leftSide!);
    }
    if (children.isNotEmpty) {
      List<Widget> allChildren = <Widget>[];
      if (parameters.addLastItemTargetHeightToTop) {
        allChildren.add(Padding(
          padding: EdgeInsets.only(top: parameters.lastItemTargetHeight),
        ));
      }
      for (int i = 0; i < children.length; i++) {
        allChildren.add(DragAndDropItemWrapper(
          child: children[i],
          parameters: parameters,
        ));
        if (parameters.itemDivider != null && i < children.length - 1) {
          allChildren.add(parameters.itemDivider!);
        }
      }
      allChildren.add(DragAndDropItemTarget(
        parent: this,
        parameters: parameters,
        onReorderOrAdd: parameters.onItemDropOnLastTarget!,
        child: lastTarget ??
            Container(
              height: parameters.lastItemTargetHeight,
            ),
      ));
      contents.add(
        Expanded(
          child: SingleChildScrollView(
            controller: controller,
            child: Column(
                crossAxisAlignment: verticalAlignment,
                mainAxisSize: MainAxisSize.max,
                children: [
                  MobilePagination(
                      scrollController: controller!,
                      pagination: pagination,
                      isLoading: isPaginationLoading,
                      onPageChange: onPageChange,
                      listWidget: (context, isLastPage, itemCount) {
                        return Column(
                          children: [
                            ...allChildren,
                            if (!isLastPage)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 8),
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              )
                          ],
                        );
                      },
                      itemCount: allChildren.length)
                ]),
          ),
        ),
      );
    } else {
      contents.add(
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                emptyState!,
                DragAndDropItemTarget(
                  parent: this,
                  parameters: parameters,
                  onReorderOrAdd: parameters.onItemDropOnLastTarget!,
                  child: lastTarget ??
                      Container(
                        height: parameters.lastItemTargetHeight,
                      ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    if (rightSide != null) {
      contents.add(rightSide!);
    }
    return contents;
  }
}
