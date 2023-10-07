
import 'package:drag_and_drop_lists/mobile_pagination/base_equatable.dart';

class PipelineBasePagination extends BaseEquatable {
  final int currentPage;
  final int? from;
  final int lastPage;
  final int perPage;
  final int? to;
  final int? total;
  PipelineBasePagination({
    required this.currentPage,
    this.from,
    required this.lastPage,
    this.perPage = 10,
    this.to,
    required this.total,
    int? limit,
    int? page,
  });
  bool get isLastPage => currentPage == lastPage;
  int get nextPage => (currentPage) + 1;
}
