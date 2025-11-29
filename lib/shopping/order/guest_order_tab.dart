import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/auth.dart';

import 'completed_orders.dart';
import 'guest_order_history.dart';
import 'upcoming_orders.dart';

class GuestOrderTab extends StatefulWidget {
  const GuestOrderTab({Key? key}) : super(key: key);

  @override
  State<GuestOrderTab> createState() => _GuestOrderTabState();
}

class _GuestOrderTabState extends State<GuestOrderTab> {
  Future<bool> _onWillPop() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(10.0),
          ),
        ),
        title: Text('Are you sure?'),
        content: Text(
          'Do you want to logout ?',
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('No'),
          ),
          TextButton(
            onPressed: () async {
              await Auth.logoutGuest();
              Get.offAllNamed('/ecommerce');
            },
            child: Text('Yes'),
          ),
        ],
      ),
    );

    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Order"),
        ),
        body: SafeArea(
          child: DefaultTabController(
            length: 3,
            child: Scaffold(
              appBar: PreferredSize(
                preferredSize: const Size.fromHeight(55),
                child: Container(
                  padding: EdgeInsets.only(top: 10),
                  color: Colors.white,
                  child: SafeArea(
                    child: Container(
                      color: Colors.white,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                            // width: MediaQuery.of(context).size.width,
                            color: Colors.white,
                            child: TabBar(
                              indicatorPadding: EdgeInsets.all(0),
                              indicatorWeight: 4.0,
                              indicatorSize: TabBarIndicatorSize.label,
                              // indicatorColor: Colors.yellow,
                              indicator: BoxDecoration(borderRadius: BorderRadius.circular(10), color: Colors.green, border: Border.all(color: Colors.black, width: 1)),
                              labelColor: Colors.black,
                              isScrollable: true,
                              unselectedLabelColor: Colors.black54,
                              tabs: [
                                Container(
                                  padding: EdgeInsets.only(top: 5, bottom: 0, left: 4, right: 4),
                                  child: Text(
                                    'Upcoming',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.only(top: 5, bottom: 0, left: 4, right: 4),
                                  child: Text(
                                    'Completed',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),
                                Container(
                                  // alignment: Alignment.center,
                                  padding: EdgeInsets.only(top: 5, bottom: 0, left: 4, right: 4),
                                  child: Center(
                                    child: Text(
                                      'History',
                                      style: TextStyle(fontSize: 18),
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              body: TabBarView(
                children: <Widget>[
                  UpcomingOrder(),
                  GuestCompletedOrder(),
                  GuestOrderHistory(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
