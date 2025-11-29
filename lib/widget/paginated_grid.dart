import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paginator_ns/flutter_paginator.dart';
import 'package:flutter_paginator_ns/type_definitions.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';

import '../widget/theme.dart';

class PaginatedGrid extends StatefulWidget {
  final String? pageTitle;
  final String? noDataTitle;
  final Future<Response> Function(int page)? apiFuture;
  final Widget Function(dynamic item, int index)? listItemBuilder;
  final dynamic Function(dynamic item)? listItemGetter;
  final bool? showLoader;
  final Widget Function()? loadingWidgetBuilder;
  final Widget? emptyListWidgetBuilder;
  final Widget? floatingActionButton;
  final List<Widget>? appBarAction;
  final bool? resetStateOnRefresh;
  final bool? listWithoutAppbar;
  final double? layoutHeight;
  final refreshPerformActionCallback;
  final bool isPrimaryList;
  final ScrollPhysics? scrollPhysics;

  const PaginatedGrid({
    Key? key,
    @required this.apiFuture,
    @required this.listItemBuilder,
    this.pageTitle,
    this.listItemGetter,
    this.showLoader = false,
    this.loadingWidgetBuilder,
    this.emptyListWidgetBuilder,
    this.floatingActionButton,
    this.resetStateOnRefresh = false,
    this.noDataTitle,
    this.refreshPerformActionCallback,
    this.listWithoutAppbar = false,
    this.appBarAction,
    this.isPrimaryList = true,
    this.scrollPhysics,
    this.layoutHeight = 0.15,
  })  : assert(apiFuture != null),
        assert(listItemBuilder != null),
        super(key: key);

  @override
  PaginatedGridState createState() => PaginatedGridState();
}

class PaginatedGridState extends State<PaginatedGrid> {
  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  final GlobalKey<PaginatorState> paginationKey = GlobalKey();

  void refreshData() {
    paginationKey.currentState!.changeState(
      pageLoadFuture: pageLoadFuture,
      resetState: widget.resetStateOnRefresh!,
    );
    if (widget.refreshPerformActionCallback != null)
      widget.refreshPerformActionCallback();
  }

  @override
  Widget build(BuildContext context) {
    return widget.listWithoutAppbar!
        ? _buildPaginatedGridWithoutAppbar()
        : Scaffold(
            backgroundColor: Colors.white,
            appBar: widget.pageTitle != null
                ? AppBar(
                    elevation: 2.0,
                    title: Text(
                      widget.pageTitle!,
                    ),
                    actions: widget.appBarAction != null
                        ? widget.appBarAction
                        : [
                            IconButton(
                              key: refreshIndicatorKey,
                              onPressed: () {
                                paginationKey.currentState!.changeState(
                                  pageLoadFuture: pageLoadFuture,
                                  resetState: true,
                                );
                              },
                              icon: Icon(
                                Icons.refresh,
                              ),
                            ),
                          ],
                  )
                : null,
            body: Column(
              children: <Widget>[
                Expanded(
                  child: Paginator.gridView(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 4.0,
                        mainAxisSpacing: 4.0,
                        childAspectRatio: 0.53),
                    key: paginationKey,
                    shrinkWrap: true,
                    primary: widget.isPrimaryList,
                    pageLoadFuture: pageLoadFuture,
                    pageItemsGetter: pageItemsGetter,
                    listItemBuilder: widget.listItemBuilder!,
                    loadingWidgetBuilder: loadingWidgetBuilder,
                    errorWidgetBuilder: errorWidgetBuilder,
                    emptyListWidgetBuilder: emptyListWidgetBuilder,
                    totalItemsGetter: totalPagesGetter,
                    pageErrorChecker: pageErrorChecker,
                    scrollPhysics: (widget.scrollPhysics != null)
                        ? widget.scrollPhysics
                        : RangeMaintainingScrollPhysics(),
                  ),
                )
              ],
            ),
            floatingActionButton: widget.floatingActionButton,
          );
  }

  Future<Pagination> pageLoadFuture(int page) async {
    try {
      Response response = await widget.apiFuture!(page);
      return Pagination.fromResponse(response);
    } catch (e) {
      if (e is IOException) {
        return Pagination.withError('Please check your Internet connection');
      } else {
        return Pagination.withError('Something went wrong.');
      }
    }
  }

  List<dynamic> pageItemsGetter(Pagination pagination) {
    List<dynamic> list = [];

    pagination.items!.forEach((item) {
      if (widget.listItemGetter != null) {
        list.add(widget.listItemGetter!(item));
      } else {
        list.add(item);
      }
    });

    return list;
  }

  Widget loadingWidgetBuilder() {
    if (widget.showLoader == false) {
      return SizedBox.shrink();
    }

    if (widget.loadingWidgetBuilder != null) {
      return widget.loadingWidgetBuilder!();
    }

    return Container(
      alignment: Alignment.center,
      height: 160.0,
      child: CircularProgressIndicator(),
    );
  }

  Widget errorWidgetBuilder(
      Pagination pagination, RetryListener retryListener) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(pagination.errorMessage!),
        ),
        TextButton(
          onPressed: retryListener,
          child: CustomButton(
            textContent: 'Retry',
            onPressed: retryListener,
          ),
        )
      ],
    );
  }

  Widget _buildPaginatedGridWithoutAppbar() {
    return LiquidPullToRefresh(
      key: refreshIndicatorKey,
      color: colorPrimary,
      onRefresh: () async {
        refreshData();
      },
      child: Column(
        children: <Widget>[
          Expanded(
            child: Paginator.gridView(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 4.0,
                mainAxisSpacing: 4.0,
              ),
              key: paginationKey,
              shrinkWrap: true,
              pageLoadFuture: pageLoadFuture,
              pageItemsGetter: pageItemsGetter,
              listItemBuilder: widget.listItemBuilder!,
              loadingWidgetBuilder: loadingWidgetBuilder,
              errorWidgetBuilder: errorWidgetBuilder,
              emptyListWidgetBuilder: emptyListWidgetBuilder,
              totalItemsGetter: totalPagesGetter,
              pageErrorChecker: pageErrorChecker,
              scrollPhysics: BouncingScrollPhysics(),
            ),
          )
        ],
      ),
    );
  }

  Widget emptyListWidgetBuilder(Pagination pagination) {
    if (widget.emptyListWidgetBuilder != null) {
      return widget.emptyListWidgetBuilder!;
    }

    return Center(
      child: emptyWidget(
        context,
        'assets/images/no_data_found.png',
        "No Data Found in ${widget.pageTitle == null ? widget.noDataTitle : widget.pageTitle}",
        "There was no record based on the details you entered.",
      ),
    );
  }

  int totalPagesGetter(Pagination pagination) {
    return pagination.total!;
  }

  bool pageErrorChecker(Pagination pagination) {
    return pagination.statusCode != 200;
  }
}

class Pagination {
  List<dynamic>? items;
  int? statusCode;
  String? errorMessage;
  int? total;
  int? nItems;

  Pagination.fromResponse(Response response) {
    this.statusCode = response.statusCode;
    items = response.data['list']['data'];
    total = response.data['list']['total'];
    nItems = items!.length;
  }

  Pagination.withError(String errorMessage) {
    this.errorMessage = errorMessage;
  }
}
