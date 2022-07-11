import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';
import 'package:investire/item.dart';
import 'package:get_storage/get_storage.dart'; // https://pub.dev/packages/get_storage

Future<void> main() async {
  await GetStorage.init();
  runApp(MaterialApp(
    home: const Investire(),
    title: 'Investire',
    theme: ThemeData(
      primarySwatch: Colors.grey,
      visualDensity: VisualDensity.adaptivePlatformDensity,
    ),
  ));
}

class Investire extends StatefulWidget {
  const Investire({Key? key}) : super(key: key);

  @override
  State<Investire> createState() => _InvestireState();
}

class _InvestireState extends State<Investire> {
  var _currentIndex = 0;
  final _boughtItems = <BoughtItem>[];
  final _soldItems = <SoldItem>[];
  final box = GetStorage();
  final lineSplitter = const LineSplitter();

  @override
  void initState() {
    // box.erase();
    /// Retrieve _boughtItems from storage
    for (var i = 0; box.read('bought-$i') != null; i++) {
      var boughtList = lineSplitter.convert(box.read('bought-$i'));
      _boughtItems.add(
        BoughtItem(
          name: boughtList[0],
          boughtPrice: int.parse(boughtList[1]),
          boughtWhen: DateTime.parse(boughtList[2]),
          comments: boughtList[3],
        ),
      );
    }
    /// Retrieve _soldItems from storage
    for (var i = 0; box.read('sold-$i') != null; i++) {
      var soldList = lineSplitter.convert(box.read('sold-$i'));
      _soldItems.add(
        SoldItem(
          name: soldList[0],
          boughtPrice: int.parse(soldList[1]),
          soldPrice: int.parse(soldList[2]),
          boughtWhen: DateTime.parse(soldList[3]),
          soldWhen: DateTime.parse(soldList[4]),
          comments: soldList[5],
        ),
      );
    }
    _soldItems.sort((a, b) => a.name.compareTo(b.name));
    super.initState();
  }

  void save() {
    box.erase();

    /// Save _boughtItems to storage
    for (var i = 0; i < _boughtItems.length; i++) {
      box.write('bought-$i',
          '${_boughtItems[i].name}\n${_boughtItems[i].boughtPrice}\n${_boughtItems[i].boughtWhen}\n${_boughtItems[i].comments}\n');
    }

    /// Save _soldItems to storage
    for (var i = 0; i < _soldItems.length; i++) {
      box.write('sold-$i',
          '${_soldItems[i].name}\n${_soldItems[i].boughtPrice.toString()}\n${_soldItems[i].soldPrice.toString()}\n${_soldItems[i].boughtWhen.toString()}\n${_soldItems[i].soldWhen.toString()}\n${_soldItems[i].comments}\n');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Investire'),
      ),
      body: [
        /// Bought page
        Scaffold(
          body: ListView.builder(
            padding: const EdgeInsets.only(top: 10.0),
            itemCount: _boughtItems.length,
            itemBuilder: (context, index) => ListTile(
              title: Text(_boughtItems[index].name),
              dense: true,
              onTap: () {},
              subtitle: Text(
                  'Bought for ${_boughtItems[index].boughtPrice.toString()}ᴘ on ${DateFormat('dd/MM/yyyy').format(_boughtItems[index].boughtWhen)}\n${_boughtItems[index].comments == '' ? '' : 'Comments: ${_boughtItems[index].comments}'}'),
              trailing: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () {
                      int itemSoldPrice = 1;
                      DateTime itemSoldWhen = DateTime.now();
                      String itemComments = '';

                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Sell'),
                          content: SingleChildScrollView(
                            child: ListBody(
                              children: [
                                /// Sold price field
                                TextField(
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Sale',
                                    isDense: true,
                                  ),
                                  maxLength: 10,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  onChanged: (value) =>
                                      itemSoldPrice = int.parse(value),
                                ),
                                const SizedBox(height: 20),

                                /// Sold date picker
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey,
                                      width: 1,
                                    ),
                                    borderRadius: const BorderRadius.all(
                                      Radius.circular(5.0),
                                    ),
                                  ),
                                  width: 300,
                                  height: 275,
                                  child: CalendarDatePicker(
                                    initialDate: DateTime.now(),
                                    firstDate: _boughtItems[index].boughtWhen,
                                    lastDate: DateTime.now().add(
                                      const Duration(days: 365),
                                    ),
                                    onDateChanged: (dateTime) =>
                                        itemSoldWhen = dateTime,
                                  ),
                                ),
                                const SizedBox(height: 20),

                                /// New comments field
                                TextField(
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    labelText: 'Additional comments',
                                    isDense: true,
                                  ),
                                  maxLength: 200,
                                  onChanged: (value) => itemComments = value,
                                ),
                              ],
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                                setState(() {
                                  _soldItems.add(SoldItem(
                                      name: _boughtItems[index].name,
                                      boughtPrice:
                                          _boughtItems[index].boughtPrice,
                                      soldPrice: itemSoldPrice,
                                      boughtWhen:
                                          _boughtItems[index].boughtWhen,
                                      soldWhen: itemSoldWhen,
                                      comments:
                                          '${_boughtItems[index].comments}${_boughtItems[index].comments != '' && itemComments != '' ? ', ' : ''}${itemComments == '' ? '' : '$itemComments (sell)'}'));
                                  _soldItems
                                      .sort((a, b) => a.name.compareTo(b.name));
                                  _boughtItems.removeAt(index);
                                  save();
                                });
                              },
                              child: const Text('Approve.'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Column(
                      children: const [
                        Icon(Icons.attach_money),
                        Text('Sell', style: TextStyle(fontSize: 7)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 5),
                  TextButton(
                    onPressed: null,
                    onLongPress: () {
                      setState(() => _boughtItems.removeAt(index));
                      save();
                    },
                    child: Column(
                      children: const [
                        Icon(Icons.delete_outline),
                        Text('Delete (hold)', style: TextStyle(fontSize: 7)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              String itemName = 'Unnamed';
              int itemBoughtPrice = 1;
              DateTime itemBoughtWhen = DateTime.now();
              String itemComments = '';

              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Add'),
                  content: SingleChildScrollView(
                    child: ListBody(
                      children: [
                        /// Name field
                        TextField(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Name',
                            isDense: true,
                          ),
                          maxLength: 100,
                          onChanged: (value) => itemName = value,
                        ),
                        const SizedBox(height: 20),

                        /// Price field
                        TextField(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Price',
                            isDense: true,
                          ),
                          maxLength: 10,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          onChanged: (value) =>
                              itemBoughtPrice = int.parse(value),
                        ),
                        const SizedBox(height: 20),

                        /// Bought date picker
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.grey,
                              width: 1,
                            ),
                            borderRadius: const BorderRadius.all(
                              Radius.circular(5.0),
                            ),
                          ),
                          width: 300,
                          height: 275,
                          child: CalendarDatePicker(
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1969),
                              lastDate:
                                  DateTime.now().add(const Duration(days: 365)),
                              onDateChanged: (dateTime) =>
                                  itemBoughtWhen = dateTime),
                        ),
                        const SizedBox(height: 20),

                        /// Comments field
                        TextField(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Comments',
                            isDense: true,
                          ),
                          maxLength: 200,
                          onChanged: (value) {
                            itemComments = value;
                          },
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        setState(() {
                          _boughtItems.add(BoughtItem(
                              name: itemName,
                              boughtPrice: itemBoughtPrice,
                              boughtWhen: itemBoughtWhen,
                              comments:
                                  '$itemComments${itemComments == '' ? '' : ' (buy)'}'));
                          _boughtItems.sort((a, b) => a.name.compareTo(b.name));
                          save();
                        });
                      },
                      child: const Text('Approve.'),
                    )
                  ],
                ),
              );
            },
            label: const Text('Add'),
            icon: const Icon(Icons.add),
            foregroundColor: Colors.white,
          ),
        ),

        /// Sold Page
        Scaffold(
          body: ListView.builder(
            padding: const EdgeInsets.only(top: 10.0),
            itemCount: _soldItems.length,
            itemBuilder: (context, index) => ListTile(
              title: Text(_soldItems[index].name),
              dense: true,
              onTap: () {},
              subtitle: Text(
                  'Bought for ${_soldItems[index].boughtPrice}ᴘ on ${DateFormat('dd/MM/yyyy').format(_soldItems[index].boughtWhen)}\nSold for ${_soldItems[index].soldPrice}ᴘ on ${DateFormat('dd/MM/yyyy').format(_soldItems[index].soldWhen)}\n${_soldItems[index].profitPercentPerDay}% daily profit (${_soldItems[index].profitPercent}% in ${_soldItems[index].daysTaken}${_soldItems[index].daysTaken == 1 ? ' day' : ' days'})\n${_soldItems[index].comments == '' ? '' : 'Comments: ${_soldItems[index].comments}'}'),
              trailing: TextButton(
                onPressed: null,
                onLongPress: () {
                  setState(() => _soldItems.removeAt(index));
                  save();
                },
                child: Column(
                  children: const [
                    Icon(Icons.delete_outline),
                    Text('Delete (hold)', style: TextStyle(fontSize: 7)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ][_currentIndex],
      bottomNavigationBar: SalomonBottomBar(
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        items: [
          SalomonBottomBarItem(
              icon: const Icon(Icons.class_),
              title: const Text('Bought'),
              selectedColor: Colors.lightBlueAccent),
          SalomonBottomBarItem(
              icon: const Icon(Icons.checklist),
              title: const Text('Sold'),
              selectedColor: Colors.pinkAccent),
        ],
      ),
    );
  }
}
