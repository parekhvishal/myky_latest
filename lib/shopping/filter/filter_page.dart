import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:unicons/unicons.dart';

import '../../../services/api.dart';
import '../../../services/extension.dart';
import '../../../services/size_config.dart';
import '../../../widget/filterWidget.dart';
import '../../../widget/theme.dart';

class FilterPage extends StatefulWidget {
  final dynamic Function(dynamic item) filterData;

  const FilterPage({Key? key, required this.filterData}) : super(key: key);

  @override
  _FilterPageState createState() => _FilterPageState();
}

class _FilterPageState extends State<FilterPage> {
  List short = [];
  List genderData = [];
  List categoryData = [];

  List filter = [];
  List subFilter = [];

  List selectedGender = [];
  List selectedCategory = [];

  Map<String, List> selectedFilter = {
    'categories': [],
    'gender': [],
    'price': [],
    'ratings': [],
    'discount': [],
  };

  int? shortValue = 1;
  int? selectedShortValue = 2;
  int? productCount;

  Map? selectedIndex;

  Future? filterFuture;

  String? filterType;

  TextEditingController categorySearchController = TextEditingController();

  Future<Map> getFilterData() {
    return Api.httpWithoutLoader.get("shopping/filter-details").then((response) {
      setState(() {
        selectedIndex = response.data['filters'][0];
        subFilter = response.data['filters'][0]['value'];
      });
      return response.data;
    });
  }

  @override
  void initState() {
    filterFuture = getFilterData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // SizeConfig().init(context);
    return FutureBuilder(
      future: filterFuture,
      builder: (context, AsyncSnapshot? snapshot) {
        if (!snapshot!.hasData) {
          return Center();
        }

        productCount = snapshot.data['productCount'];
        short = snapshot.data['shortBy'];

        genderData = snapshot.data['gender'];
        genderData.map((gnd) {
          gnd.putIfAbsent('isSelected', () => false);
        }).toList();

        categoryData = snapshot.data['category'];
        categoryData.map((cat) {
          cat.putIfAbsent('isSelected', () => false);
        }).toList();

        filter = snapshot.data['filters'];

        return FilterWidget(
          filterSort: () {
            showModalBottomSheet(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              context: context,
              builder: (builder) {
                return StatefulBuilder(
                  builder: (context, setState) {
                    return Container(
                      height: h(65.0),
                      color: Colors.transparent,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                text(
                                  'sort',
                                  textAllCaps: true,
                                  fontFamily: fontSemibold,
                                ),
                                IconButton(
                                  icon: Icon(UniconsLine.sorting),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                          ),
                          Divider(thickness: 1),
                          Expanded(
                            child: ListView.builder(
                              itemCount: short.length,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                return RadioListTile(
                                  value: index,
                                  groupValue: shortValue,
                                  onChanged: (val) {
                                    setState(() {
                                      shortValue = val as int?;
                                      selectedShortValue = short[index]['id'];
                                    });
                                  },
                                  title: text(short[index]['name'], fontFamily: fontMedium),
                                  activeColor: colorAccent,
                                  controlAffinity: ListTileControlAffinity.trailing,
                                );
                              },
                            ),
                          ),
                          Divider(thickness: 1),
                          buildDoneButton(context),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
          filterCategory: () {
            showModalBottomSheet(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              isScrollControlled: true,
              context: context,
              builder: (builder) {
                return StatefulBuilder(
                  builder: (context, setState) {
                    return Container(
                      height: h(80.0),
                      color: Colors.transparent,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                text(
                                  'Category',
                                  textAllCaps: true,
                                  fontFamily: fontSemibold,
                                ),
                                IconButton(
                                  icon: Icon(UniconsLine.multiply),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                          ),
                          Divider(thickness: 1),
                          // Padding(
                          //   padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          //   child: TextFormField(
                          //     decoration: InputDecoration(
                          //       hintText: "Search Category",
                          //       border: OutlineInputBorder(
                          //         borderSide: BorderSide(width: 32.0),
                          //         borderRadius: BorderRadius.circular(10.0),
                          //       ),
                          //     ),
                          //     controller: categorySearchController,
                          //     onChanged: onSearchTextChanged,
                          //
                          //     // trailing: IconButton(
                          //     //   icon: Icon(Icons.cancel),
                          //     //   onPressed: () {
                          //     //     searchController.clear();
                          //     //     onSearchTextChanged('');
                          //     //   },
                          //     // ),
                          //   ),
                          // ),
                          // Divider(
                          //   thickness: 1,
                          //   indent: 50.0,
                          //   endIndent: 50.0,
                          // ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: categoryData.length,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                return CheckboxListTile(
                                  title: text(categoryData[index]['name']),
                                  onChanged: (bool? value) {
                                    setState(() {
                                      categoryData[index]['isSelected'] = !categoryData[index]['isSelected'];
                                      value = categoryData[index]['isSelected'];
                                      if (value!) {
                                        setState(() {
                                          if (selectedCategory.length == 0) {
                                            selectedCategory.add(
                                              {"id": categoryData[index]['id']},
                                            );
                                          } else {
                                            int i = selectedCategory.indexWhere((m) => m["id"] == categoryData[index]['id']);

                                            if (i == -1) {
                                              selectedCategory.add(
                                                {
                                                  "id": categoryData[index]['id'],
                                                },
                                              );
                                            }
                                          }
                                        });
                                      } else if (!categoryData[index]['isSelected']) {
                                        for (int i = 0; i < selectedCategory.length; i++) {
                                          if (selectedCategory[i]['id'] == categoryData[index]['id']) {
                                            setState(() {
                                              selectedCategory.removeAt(i);
                                            });
                                          }
                                        }
                                      }
                                    });

                                    selectedFilter['categories']!.clear();
                                    selectedCategory.map((category) {
                                      selectedFilter['categories']!.add(category['id']);
                                    }).toList();
                                  },
                                  value: categoryData[index]['isSelected'],
                                );
                              },
                            ),
                          ),
                          Divider(thickness: 1),
                          buildDoneButton(context),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
          filterGender: () {
            showModalBottomSheet(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              context: context,
              builder: (builder) {
                return StatefulBuilder(
                  builder: (context, setState) {
                    return Container(
                      height: h(37.0),
                      color: Colors.transparent,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                text(
                                  'Gender',
                                  textAllCaps: true,
                                  fontFamily: fontSemibold,
                                ),
                                IconButton(
                                  icon: Icon(UniconsLine.multiply),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                          ),
                          Divider(thickness: 1),
                          Expanded(
                            child: ListView.builder(
                              itemCount: genderData.length,
                              scrollDirection: Axis.horizontal,
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                  child: Container(
                                    child: Column(
                                      children: [
                                        Container(
                                          width: 60.0,
                                          height: 60.0,
                                          decoration: BoxDecoration(
                                            color: const Color(0xff7c94b6),
                                            image: DecorationImage(
                                              image: NetworkImage(genderData[index]['image']),
                                              fit: BoxFit.cover,
                                            ),
                                            borderRadius: BorderRadius.all(Radius.circular(50.0)),
                                            border: Border.all(
                                              color: genderData[index]['isSelected'] ? Colors.red : Colors.white,
                                              width: 4.0,
                                            ),
                                          ),
                                        ),
                                        SizedBox(height: 8.0),
                                        text(
                                          genderData[index]['name'],
                                          fontFamily: fontMedium,
                                        ),
                                      ],
                                    ),
                                  ).onClick(() {
                                    setState(() {
                                      genderData[index]['isSelected'] = !genderData[index]['isSelected'];

                                      bool? value = genderData[index]['isSelected'];
                                      if (value!) {
                                        setState(() {
                                          if (selectedGender.length == 0) {
                                            selectedGender.add(
                                              {"id": genderData[index]['id']},
                                            );
                                          } else {
                                            int i = selectedGender.indexWhere((m) => m["id"] == genderData[index]['id']);

                                            if (i == -1) {
                                              selectedGender.add(
                                                {
                                                  "id": genderData[index]['id'],
                                                },
                                              );
                                            }
                                          }
                                        });
                                      } else if (!genderData[index]['isSelected']) {
                                        for (int i = 0; i < selectedGender.length; i++) {
                                          if (selectedGender[i]['id'] == genderData[index]['id']) {
                                            setState(() {
                                              selectedGender.removeAt(i);
                                            });
                                          }
                                        }
                                      }

                                      selectedFilter['gender']!.clear();
                                      selectedGender.map((gender) {
                                        selectedFilter['gender']!.add(gender['id']);
                                      }).toList();
                                    });
                                  }),
                                );
                              },
                            ),
                          ),
                          Divider(thickness: 1),
                          buildDoneButton(context),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
          filterData: () {
            showModalBottomSheet(
              isScrollControlled: true,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              context: context,
              builder: (builder) {
                return StatefulBuilder(
                  builder: (context, setState) {
                    return Container(
                      height: h(90.0),
                      color: Colors.transparent,
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                text(
                                  'Filters',
                                  textAllCaps: true,
                                  fontFamily: fontSemibold,
                                ),
                                IconButton(
                                  icon: Icon(UniconsLine.multiply),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            ),
                          ),
                          Divider(thickness: 2),
                          Expanded(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Container(
                                    height: h(100),
                                    color: Colors.grey.shade300,
                                    child: buildFilterList(setState),
                                  ),
                                ),
                                Expanded(
                                  flex: 8,
                                  child: Column(
                                    children: [
                                      if (selectedIndex != null)
                                        Align(
                                          alignment: Alignment.topLeft,
                                          child: text(
                                            selectedIndex!['name'],
                                            textAllCaps: true,
                                          ),
                                        ),
                                      Expanded(
                                        child: Container(
                                          height: h(100),
                                          child: buildSubFilterList(context, setState),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                          Divider(thickness: 1),
                          buildDoneButton(context),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Widget buildDoneButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          text(
            '$productCount + Product',
            textAllCaps: true,
            fontFamily: fontSemibold,
          ),
          MaterialButton(
            onPressed: () {
              widget.filterData({
                "sort": selectedShortValue,
                "filter": selectedFilter,
              });
              Navigator.pop(context);
            },
            elevation: 0,
            padding: const EdgeInsets.all(10.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            color: colorPrimary,
            child: text(
              'Done',
              textColor: white,
              textAllCaps: true,
              fontFamily: fontSemibold,
            ),
            //
            // Row(
            //   children: [
            //     // MaterialButton(
            //     //   onPressed: () {
            //     //     selectedFilter['categories']!.clear();
            //     //     selectedFilter['gender']!.clear();
            //     //     selectedFilter['price']!.clear();
            //     //     selectedFilter['ratings']!.clear();
            //     //     selectedFilter['discount']!.clear();
            //     //     selectedShortValue = 0;
            //     //     widget.filterData({
            //     //       "sort": selectedShortValue,
            //     //       "filter": selectedFilter,
            //     //     });
            //     //     Navigator.pop(context);
            //     //   },
            //     //   elevation: 0,
            //     //   padding: const EdgeInsets.all(10.0),
            //     //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            //     //   color: Colors.red,
            //     //   child: text('Clear', textColor: white),
            //     // ),
            //     // SizedBox(width: 10),
            //     MaterialButton(
            //       onPressed: () {
            //         widget.filterData({
            //           "sort": selectedShortValue,
            //           "filter": selectedFilter,
            //         });
            //         Navigator.pop(context);
            //       },
            //       elevation: 0,
            //       padding: const EdgeInsets.all(10.0),
            //       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            //       color: Theme.of(context).accentColor,
            //       child: text('Done', textColor: white),
            //     ),
            //   ],
          ),
        ],
      ),
    );
  }

  Widget buildFilterList(setState) {
    return ListView.builder(
      itemCount: filter.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        return Column(
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  subFilter = filter[index]['value'];
                  selectedIndex = filter[index];
                  filterType = filter[index]['type'];
                });
              },
              child: Container(
                width: w(100),
                padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                decoration: BoxDecoration(
                  color: selectedIndex == filter[index] ? white : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    text(
                      filter[index]['name'],
                      isLongText: true,
                      textAllCaps: true,
                      isCentered: true,
                      fontFamily: fontMedium,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget buildSubFilterList(BuildContext context, setState) {
    return subFilter.length > 0
        ? ListView(
            children: [
              Wrap(
                children: [
                  for (int i = 0; i < subFilter.length; i++)
                    Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: filterType == "chip"
                          ? ChoiceChip(
                              backgroundColor: white,
                              elevation: 5.0,
                              label: text(
                                subFilter[i]['name'].toString(),
                                isCentered: true,
                                isLongText: true,
                                fontSize: 15.0,
                                textColor: subFilter[i]['selected'] ? Colors.white : Colors.black,
                              ),
                              selected: true,
                              selectedColor: subFilter[i]['selected'] ? colorPrimary : null,
                              onSelected: (bool selected) {
                                subFilter.forEach((singleFilterDetail) {
                                  if (singleFilterDetail['id'] == subFilter[i]['id']) {
                                    setState(() {
                                      singleFilterDetail['selected'] = !singleFilterDetail['selected'];
                                    });
                                    if (selectedIndex!['name'] == 'gender') {
                                      fitterList(selectedList: singleFilterDetail, addList: selectedFilter['gender']);
                                    } else if (selectedIndex!['name'] == 'Price') {
                                      fitterList(selectedList: singleFilterDetail, addList: selectedFilter['price']);
                                    } else if (selectedIndex!['name'] == 'Discount') {
                                      fitterList(selectedList: singleFilterDetail, addList: selectedFilter['discount']);
                                    }
                                  }
                                });
                              },
                            )
                          : CheckboxListTile(
                              title: text(subFilter[i]['name'].toString()),
                              onChanged: (bool? value) {
                                subFilter.forEach((singleFilterDetail) {
                                  if (singleFilterDetail['id'] == subFilter[i]['id']) {
                                    setState(() {
                                      singleFilterDetail['selected'] = !singleFilterDetail['selected'];
                                    });
                                    if (selectedIndex!['name'] == 'category') {
                                      fitterList(selectedList: singleFilterDetail, addList: selectedFilter['categories']);
                                    } else if (selectedIndex!['name'] == 'Rating') {
                                      fitterList(selectedList: singleFilterDetail, addList: selectedFilter['ratings']);
                                    }
                                  }
                                });
                              },
                              value: subFilter[i]['selected'],
                            ), /*buildDynamicCheckboxListTile(i, setState),*/
                    ),
                ],
              ),
            ],
          )
        : Center(
            child: Image.asset('assets/images/results.png'),
          );
  }

  Widget buildDynamicCheckboxListTile(int i, setState, {bool isRating = true}) {
    return CheckboxListTile(
      title: text(
        subFilter[i]['name'].toString(),
        fontFamily: fontMedium,
      ),
      onChanged: (bool? value) {
        subFilter.forEach((singleFilterDetail) {
          if (singleFilterDetail['id'] == subFilter[i]['id']) {
            setState(() {
              singleFilterDetail['selected'] = !singleFilterDetail['selected'];
            });
            if (selectedIndex!['name'] == 'category') {
              fitterList(selectedList: singleFilterDetail, addList: selectedFilter['categories']);
            } else if (selectedIndex!['name'] == 'Rating' && isRating) {
              fitterList(selectedList: singleFilterDetail, addList: selectedFilter['ratings']);
            }
          }
        });
      },
      value: subFilter[i]['selected'],
    );
  }

  void fitterList({selectedList, addList}) {
    if (addList.length == 0) {
      addList.add(selectedList['id']);
    } else {
      int j = addList.indexWhere((element) => element == selectedList['id']);

      if (j == -1) {
        addList.add(selectedList['id']);
      } else {
        for (int h = 0; h < addList.length; h++) {
          if (addList[h] == selectedList['id']) {
            setState(() {
              addList.removeAt(h);
            });
          }
        }
      }
    }
    return addList;
  }
}
