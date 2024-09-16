import 'package:flutter/material.dart';
import 'package:uni_ad_portal/helper/sharedpreferenceshelper.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:uni_ad_portal/service/follow_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FollowService _followService = FollowService();
  List<dynamic> universityList = [];
  Timer? timer;

  @override
  void initState() {
    super.initState();
    fetchUniversityMajors();
    timer = Timer.periodic(
        Duration(seconds: 2), (Timer t) => fetchUniversityMajors());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  static Future<String?> getAccessToken() async {
    return Sharedpreferenceshelper.getAccessToken();
  }

  Future<void> fetchUniversityMajors() async {
    String? token = await getAccessToken();
    if (token != null) {
      final responseUniMajor = await http.get(
        Uri.parse(
            'https://uaportal.online/api/v1/follow/university/major/list'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (responseUniMajor.statusCode == 200) {
        final data = json.decode(utf8.decode(responseUniMajor.bodyBytes));
        setState(() {
          universityList = data['data'];
        });
      } else {
        print('Failed to fetch data: ${responseUniMajor.statusCode}');
      }
    } else {
      print('AccessToken is null');
    }
  }

  // Hàm để thay đổi vị trí của nguyện vọng khi kéo thả
  void reorderData(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = universityList.removeAt(oldIndex);
      universityList.insert(newIndex, item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        title: const Text(
          'Ngành học quan tâm',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        actions: [
          InkWell(
            onTap: () {},
            child: const CircleAvatar(
              backgroundImage: AssetImage('assets/student.png'),
            ),
          ),
          Stack(
            children: [
              CircleAvatar(
                backgroundColor: Colors.grey[200],
                child: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.grey,
                ),
              ),
              const Positioned(
                top: 8,
                right: 9,
                child: CircleAvatar(
                  radius: 5,
                  backgroundColor: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: universityList.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Scrollbar(
              thumbVisibility: true,
              thickness: 6.0,
              radius: const Radius.circular(20),
              child: ReorderableListView(
                onReorder: reorderData,
                children: List.generate(universityList.length, (index) {
                  final university = universityList[index];
                  return Card(
                    key: ValueKey(university['universityMajorId']),
                    margin:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: NetworkImage(university['avatar']),
                      ),
                      title: Text(
                        'Nguyện vọng ${university['index']}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Tên ngành: ${university['majorName']}'),
                          Text('Mã ngành: ${university['majorCode']}'),
                          Text('Tên trường: ${university['universityName']}'),
                          Text('Mã trường: ${university['universityCode']}'),
                        ],
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () async {
                          String? token = await getAccessToken();
                          if (token != null) {
                            await _followService.unFollowUniMajor(
                                token,
                                university['universityMajorId'].toString(),
                                context);
                          } else {
                            print('Unable to unfollow, token is null');
                          }
                        },
                      ),
                    ),
                  );
                }),
              ),
            ),
    );
  }
}
