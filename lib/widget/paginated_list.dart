import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_paginator_ns/flutter_paginator.dart';
import 'package:flutter_paginator_ns/type_definitions.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widget/theme.dart';

class PaginatedList extends StatefulWidget {
  final String? pageTitle;
  final String? noDataTitle;
  final Future<dynamic> Function(int page) apiFuture;
  final Widget Function(dynamic item, int index) listItemBuilder;
  final dynamic Function(dynamic item)? listItemGetter;
  final bool showLoader;
  final Widget Function()? loadingWidgetBuilder;
  final Widget? emptyListWidgetBuilder;
  final Widget? floatingActionButton;
  final List<Widget>? appBarAction;
  final bool resetStateOnRefresh;
  final refreshPerformActionCallback;
  final bool isPullToRefresh;
  final bool isReverse;
  final bool isDescription;

  final bool listWithoutAppbar;

  const PaginatedList({
    Key? key,
    required this.apiFuture,
    required this.listItemBuilder,
    this.pageTitle,
    this.noDataTitle,
    this.listItemGetter,
    this.showLoader = false,
    this.loadingWidgetBuilder,
    this.emptyListWidgetBuilder,
    this.floatingActionButton,
    this.appBarAction,
    this.resetStateOnRefresh = false,
    this.isPullToRefresh = true,
    this.refreshPerformActionCallback,
    this.isReverse = false,
    this.isDescription = true,
    this.listWithoutAppbar = false,
  }) : super(key: key);

  @override
  PaginatedListState createState() => PaginatedListState();
}

class PaginatedListState extends State<PaginatedList> {
  final GlobalKey<RefreshIndicatorState> liquidRefreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  final GlobalKey<RefreshIndicatorState> refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  final GlobalKey<PaginatorState> paginationKey = GlobalKey();
  SharedPreferences? preferences;

  void _refreshData() {
    paginationKey.currentState!.changeState(
      pageLoadFuture: pageLoadFuture,
      resetState: widget.resetStateOnRefresh,
    );
    if (widget.refreshPerformActionCallback != null) widget.refreshPerformActionCallback();
  }

  void refresh() {
    _refreshData();
  }

  @override
  Widget build(BuildContext context) {
    return widget.listWithoutAppbar
        ? _buildPaginatedListWithoutAppbar()
        : Scaffold(
            appBar: widget.pageTitle != null
                ? AppBar(
                    elevation: 2.0,
                    title: text(
                      widget.pageTitle!,
                      fontweight: FontWeight.bold,
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
            body: widget.isPullToRefresh
                ? LiquidPullToRefresh(
                    key: liquidRefreshIndicatorKey,
                    color: colorAccent,
                    onRefresh: () async {
                      if (widget.isPullToRefresh) _refreshData();
                    },
                    child: Column(
                      children: <Widget>[
                        Expanded(
                          child: Paginator.listView(
                            reverse: widget.isReverse,
                            key: paginationKey,
                            shrinkWrap: true,
                            pageLoadFuture: pageLoadFuture,
                            pageItemsGetter: pageItemsGetter,
                            listItemBuilder: widget.listItemBuilder,
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
                  )
                : Paginator.listView(
                    key: paginationKey,
                    shrinkWrap: true,
                    reverse: widget.isReverse,
                    pageLoadFuture: pageLoadFuture,
                    pageItemsGetter: pageItemsGetter,
                    listItemBuilder: widget.listItemBuilder,
                    loadingWidgetBuilder: loadingWidgetBuilder,
                    errorWidgetBuilder: errorWidgetBuilder,
                    emptyListWidgetBuilder: emptyListWidgetBuilder,
                    totalItemsGetter: totalPagesGetter,
                    pageErrorChecker: pageErrorChecker,
                    scrollPhysics: BouncingScrollPhysics(),
                  ),
            floatingActionButton: widget.floatingActionButton,
          );
  }

  Future<Pagination> pageLoadFuture(int page) async {
    try {
      Response response = await widget.apiFuture(page);
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

  Widget errorWidgetBuilder(Pagination pagination, RetryListener retryListener) {
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

  Widget emptyListWidgetBuilder(Pagination pagination) {
    if (widget.emptyListWidgetBuilder != null) {
      return widget.emptyListWidgetBuilder!;
    }

    return Center(
      heightFactor: 1.0,
      child: emptyWidget(
        context,
        'assets/images/no_result.png',
        "No Data Found in ${widget.pageTitle == null ? widget.noDataTitle : widget.pageTitle}",
        widget.isDescription ? "There was no record based on the details you entered." : "",
      ),
    );
  }

  int totalPagesGetter(Pagination pagination) {
    return pagination.total!;
  }

  bool pageErrorChecker(Pagination pagination) {
    return pagination.statusCode != 200;
  }

  Widget _buildPaginatedListWithoutAppbar() {
    return widget.isPullToRefresh
        ? LiquidPullToRefresh(
            key: liquidRefreshIndicatorKey,
            color: colorPrimary,
            onRefresh: () async {
              if (widget.isPullToRefresh) _refreshData();
            },
            child: Column(
              children: <Widget>[
                Expanded(
                  child: Paginator.listView(
                    reverse: widget.isReverse,
                    key: paginationKey,
                    shrinkWrap: true,
                    pageLoadFuture: pageLoadFuture,
                    pageItemsGetter: pageItemsGetter,
                    listItemBuilder: widget.listItemBuilder,
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
          )
        : Paginator.listView(
            key: paginationKey,
            shrinkWrap: true,
            reverse: widget.isReverse,
            pageLoadFuture: pageLoadFuture,
            pageItemsGetter: pageItemsGetter,
            listItemBuilder: widget.listItemBuilder,
            loadingWidgetBuilder: loadingWidgetBuilder,
            errorWidgetBuilder: errorWidgetBuilder,
            emptyListWidgetBuilder: emptyListWidgetBuilder,
            totalItemsGetter: totalPagesGetter,
            pageErrorChecker: pageErrorChecker,
            scrollPhysics: BouncingScrollPhysics(),
          );
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

  Pagination.withError(String? errorMessage) {
    this.errorMessage = errorMessage!;
  }
}
