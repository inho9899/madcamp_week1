import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Tab3Screen extends StatefulWidget {
  const Tab3Screen({super.key});

  @override
  _Tab3ScreenState createState() => _Tab3ScreenState();
}

class _Tab3ScreenState extends State<Tab3Screen> {
  List<Dday> _ddayList = [];

  @override
  void initState() {
    super.initState();
    _loadDdays();
  }

  Future<void> _pickDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      final TextEditingController _textController = TextEditingController();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('디데이 내용 입력'),
            content: TextField(
              controller: _textController,
              decoration: const InputDecoration(
                hintText: '내용을 입력하세요',
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('취소'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _ddayList.add(Dday(
                      date: pickedDate,
                      description: _textController.text,
                    ));
                    _saveDdays();
                  });
                  Navigator.of(context).pop();
                },
                child: const Text('추가'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _saveDdays() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> ddayStrings = _ddayList.map((dday) => '${dday.date.toIso8601String()},${dday.description}').toList();
    prefs.setStringList('ddays', ddayStrings);
  }

  Future<void> _loadDdays() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? ddayStrings = prefs.getStringList('ddays');
    if (ddayStrings != null) {
      setState(() {
        _ddayList = ddayStrings.map((str) {
          List<String> parts = str.split(',');
          return Dday(
            date: DateTime.parse(parts[0]),
            description: parts.sublist(1).join(','),
          );
        }).toList();
      });
    }
  }

  String _formatDate(DateTime date) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    return formatter.format(date);
  }

  int _calculateDaysRemaining(DateTime selectedDate) {
    final now = DateTime.now();
    return selectedDate.difference(now).inDays + 1;
  }

  Future<void> _deleteDday(int index) async {
    bool? confirmDelete = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('디데이 삭제'),
          content: const Text('이 디데이를 삭제하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('아니요'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('예'),
            ),
          ],
        );
      },
    );

    if (confirmDelete == true) {
      setState(() {
        _ddayList.removeAt(index);
        _saveDdays();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Add space and title here
            SizedBox(height: 16.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Icon(
                    Icons.event_note,
                    color: Color(0xFF212A3E),
                    size: 24.0,
                  ),
                  SizedBox(width: 8.0),
                  Text(
                    'D-Day 리스트',
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF212A3E),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.0),
            Expanded(
              child: ListView.builder(
                itemCount: _ddayList.length,
                itemBuilder: (context, index) {
                  Dday dday = _ddayList[index];
                  return GestureDetector(
                    onLongPress: () => _deleteDday(index),
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Color(0xFF394867).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.calendar_today, color: Colors.black, size: 24.0),
                              SizedBox(width: 8.0),
                              Text(
                                'D-${_calculateDaysRemaining(dday.date)}: ${_formatDate(dday.date)}',
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8.0),
                          Text(dday.description),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _pickDate(context),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

class Dday {
  final DateTime date;
  final String description;

  Dday({required this.date, required this.description});
}
