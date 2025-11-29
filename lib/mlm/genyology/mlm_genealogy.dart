import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:nb_utils/nb_utils.dart' hide white, log;
import 'package:unicons/unicons.dart';

import '../../services/api.dart';
import '../../services/auth.dart';
import '../../services/size_config.dart';
import '../../widget/network_image.dart';
import '../../widget/theme.dart';

class MLMGenealogy extends StatefulWidget {
  @override
  _MLMGenealogyState createState() => _MLMGenealogyState();
}

class _MLMGenealogyState extends State<MLMGenealogy> {
  int? _childCount;
  String _code = Auth.user()!['code'];
  List members = [];
  Response? genealogyDetails;
  String searchCode = '';
  List memberCodeList = [Auth.user()!['code']];
  List memberNameList = [Auth.user()!['name']];

  TextEditingController _codeController = TextEditingController();

  String? type;

  @override
  void initState() {
    type = Get.arguments;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 2.0,
        automaticallyImplyLeading: type != null ? true : false,
        title: Text('Genealogy Tree'),
        actions: <Widget>[
          IconButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20.0))),
                    content: Container(
                      height: h(70),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          infoCircularImage('#f50114', "FREE"),
                          infoCircularImage('#facc00', "INCOMPLETE KYC"),
                          infoCircularImage('#38ba4b', "ACTIVE"),
                          infoCircularImage('#323a46', "BLOCK"),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            icon: Icon(UniconsLine.info_circle),
          ),
          IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Member Code'),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            TextFormField(
                              keyboardType: TextInputType.text,
                              inputFormatters: [
                                FilteringTextInputFormatter.deny(
                                    new RegExp(r'^[- ,.]')),
                              ],
                              autofocus: true,
                              controller: _codeController,
                              decoration: InputDecoration(
                                labelText: 'Member Code',
                                hintText: 'Search by Member Code...',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ],
                        ),
                        actions: <Widget>[
                          TextButton(
                            child: Text('Cancel'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          TextButton(
                            child: Text('Search'),
                            onPressed: () {
                              FocusScope.of(context).requestFocus(FocusNode());

                              setState(() {
                                _code = _codeController.text;
                              });
                              _codeController.clear();
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    });
              })
        ],
      ),
      body: FutureBuilder(
        future: Api.http
            .get('member/sponsor-genealogy/show/$_code')
            .then((res) => res.data),
        builder: (context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          Map? rootNode = snapshot.data['tree'];
          List members = snapshot.data['tree']['children'];
          _childCount = snapshot.data['tree']['children'].length;

          // members.map((member) {
          //   // return member['color'] = "Colors.${member['imageBackground']}");
          // }).toList();

          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 18.0,
              vertical: 5,
            ),
            child: Column(
              children: <Widget>[
                Card(
                  color: Colors.grey[200],
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: <Widget>[
                        text(
                          'Go to my tree',
                        ).onTap(() {
                          setState(() {
                            _code = _codeController.text;
                            memberCodeList = [Auth.user()!['code']];
                          });
                        }),
                      ],
                    ),
                  ),
                ),
                if (memberCodeList.length > 1)
                  Row(
                    children: <Widget>[
                      Container(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                          icon: Icon(Icons.arrow_back),
                          onPressed: () {
                            setState(() {
                              memberCodeList.removeLast();
                              memberNameList.removeLast();
                              if (memberCodeList.length > 0) {
                                _code = memberCodeList.last;
                              }
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                Expanded(
                  child: Row(
                    children: <Widget>[
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Column(
                                children: <Widget>[
                                  _buildMemberIcon(rootNode!),
                                ],
                              ),
                              if (_childCount != 0)
                                Container(
                                  height: 1.0,
                                  width: 40.0,
                                  color: Colors.black,
                                ),
                            ],
                          )
                        ],
                      ),
                      SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: members
                              .asMap()
                              .map((index, member) {
                                double containerHeight = 170.0;

                                return MapEntry(
                                  index,
                                  Container(
                                    height: containerHeight,
                                    child: Row(
                                      children: <Widget>[
                                        Column(
                                          children: <Widget>[
                                            Container(
                                              child: VerticalDivider(
                                                thickness: 1,
                                                color: Colors.black,
                                              ),
                                              height: verticalDividerHeight(
                                                  index,
                                                  containerHeight,
                                                  members),
                                              width: 1,
                                            ),
                                          ],
                                          mainAxisAlignment:
                                              verticalDividerAlignment(
                                                  index, members),
                                        ),
                                        Container(
                                          child: Divider(
                                            thickness: 1,
                                            color: Colors.black,
                                          ),
                                          width: 30,
                                          height: 1,
                                        ),
                                        SizedBox(width: 10),
                                        _buildMemberIcon(member),
                                      ],
                                    ),
                                  ),
                                );
                              })
                              .values
                              .toList(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  MainAxisAlignment verticalDividerAlignment(int index, List members) {
    if (index == 0) {
      return MainAxisAlignment.end;
    } else if ((index + 1) == members.length) {
      return MainAxisAlignment.start;
    }

    return MainAxisAlignment.center;
  }

  double verticalDividerHeight(
      int index, double containerHeight, List members) {
    if (index == 0 || (index + 1) == members.length) {
      return containerHeight / 2;
    }

    return containerHeight;
  }

  Widget _buildMemberIcon(Map node) {
    return Container(
      margin: EdgeInsets.only(top: 30),
      child: Column(
        children: <Widget>[
          GestureDetector(
            child: circularImage(
                svg: node['isSvg'],
                image: node['image'],
                color: node['imageBackground']),
            onTap: () {
              if (memberCodeList.length == 0) {
                memberCodeList.add(node['code']);
                memberNameList.add(node['name']);
                setState(() {
                  _code = node['code'];
                });
              } else {
                int _index =
                    memberCodeList.indexWhere((code) => code == node['code']);
                if (_index == -1) {
                  memberCodeList.add(node['code']);
                  memberNameList.add(node['name']);
                  setState(() {
                    _code = node['code'];
                  });
                }
              }
            },
          ),
          SizedBox(height: 5),
          GestureDetector(
              child: Text(
                node['code'],
                style: TextStyle(
                    color: node['isPromotor'] == true
                        ? Colors.green
                        : colorPrimary),
              ),
              onTap: () {
                if (node['code'] != '') showDialogMemberInfo(node);
              }),
          SizedBox(height: 5),
          Container(
            width: w(30),
            child: GestureDetector(
              child: Text(
                node['name'],
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 12),
              ),
              onTap: () {},
            ),
          ),
          SizedBox(height: 5),
        ],
      ),
    );
  }

  showDialogMemberInfo(node) {
    Get.dialog(Material(
      type: MaterialType.transparency,
      child: Center(
        child: memberInfoWidget(node),
      ),
    ));
  }

  Widget memberInfoWidget(node) {
    return Container(
      width: w(90),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: white,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: w(90),
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                  colors: [
                    node['isPromotor'] == true ? Colors.green : colorPrimary,
                    node['isPromotor'] == true
                        ? Colors.green.withOpacity(0.3)
                        : colorPrimary.withOpacity(0.3),
                  ],
                  begin: const FractionalOffset(0.0, 0.0),
                  end: const FractionalOffset(1.0, 1.0),
                  stops: [0.0, 1.0],
                  tileMode: TileMode.clamp),
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      // dialog top
                      10.height,
                      _rowForMemberInfo('Name:', node['name']),
                      5.height,
                      _rowForMemberInfo('Joining Date:', node['joiningDate']),
                      5.height,
                      _rowForMemberInfo(
                          'Activation Date:', node['activationDate'] ?? "N/A"),
                      if (node['sponsorName'] != null) ...[
                        5.height,
                        _rowForMemberInfo('Sponsor Name', node['sponsorName']),
                      ],
                      if (node['sponsorCode'] != null) ...[
                        5.height,
                        _rowForMemberInfo('Sponsor Id:', node['sponsorCode']),
                      ],
                      5.height,
                      _rowForMemberInfo(
                          'Direct:', node['sponsoredCount'].toString()),
                      5.height,
                      _rowForMemberInfo(
                          'Current Month Purchase/Current Month Purchase Required:',
                          "${node['currentMonthPurchase'] ?? "N/A"} / ${node['currentMonthPurchaseRequire'] ?? "N/A"}"),
                    ],
                  ),
                ),
                Positioned(
                  right: 0,
                  child: IconButton(
                    icon: Icon(
                      Icons.close,
                      size: 25,
                      color: Colors.black87,
                    ),
                    onPressed: () {
                      Get.back();
                    },
                  ),
                )
              ],
            ),
          ),
          10.height,
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              text(
                node['code'],
                fontSize: 20.0,
                fontFamily: fontBold,
                textColor: Colors.black87,
              ),
              10.width,
              InkWell(
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(text: node['code']),
                  );
                  GetBar(
                    duration: Duration(seconds: 1),
                    message: 'Member ID copied to clipboard',
                    backgroundColor: green,
                  ).show();
                },
                child: Icon(
                  Icons.content_copy,
                  size: 22,
                  color: colorPrimary,
                ),
              )
            ],
          ),
          10.height,
        ],
      ),
    );
  }

  Widget _rowForMemberInfo(String label1, String label2) {
    return Row(
      children: [
        Expanded(
          flex: 50,
          child: text(
            label1,
            textColor: Colors.black,
            fontSize: 14.0,
            maxLine: 2,
            isLongText: true,
          ),
        ),
        Expanded(
          flex: 40,
          child: text(
            label2 ?? "N/A",
            textColor: Colors.black,
            fontFamily: fontBold,
            fontSize: 16.0,
            maxLine: 2,
            isLongText: true,
          ),
        ),
      ],
    );
  }

  Widget circularImage({String? color, String? image, bool? svg}) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: HexColor(color!),
          width: 2.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.all(Radius.circular(50.0)),
        child: svg!
            ? SvgPicture.network(
                image!,
                height: 50,
                placeholderBuilder: (context) => Center(
                  child: CircularProgressIndicator(),
                ),
              )
            : PNetworkImage(image),
      ),
      height: 60,
      width: 60,
    );
  }

  Widget infoCircularImage(String color, String name, {String? subName}) {
    return Column(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: HexColor(
                color,
              ),
              width: 2.5,
            ),
          ),
          child: Column(
            children: <Widget>[
              ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(50.0)),
                child: SvgPicture.asset(
                  'assets/images/user_blank.svg',
                  height: 50,
                  placeholderBuilder: (context) => Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ),
            ],
          ),
          height: 60,
          width: 60,
        ),
        SizedBox(height: 5),
        text(name),
        if (subName != null) ...[
          SizedBox(height: 5),
          text(subName),
        ],
      ],
    );
  }
}
