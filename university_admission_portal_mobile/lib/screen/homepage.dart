import 'package:flutter/material.dart';
import 'package:uni_ad_portal/helper/sharedpreferenceshelper.dart';
import 'package:http/http.dart' as http;
import 'package:uni_ad_portal/models/userInfo.dart';
import 'package:uni_ad_portal/screen/account_screen.dart';
import 'package:uni_ad_portal/screen/login.dart';
import 'dart:convert';
import 'dart:async';
import 'package:uni_ad_portal/service/follow_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FollowService _followService = FollowService();
  List<dynamic> universityList = [];
  Timer? timer;
  String? accessToken;
  late Future _initAccount;
  String avatar = "";

  Info? account;

  @override
  void initState() {
    super.initState();
    _initAccount = getInfo();
    _initAccount.then(
      (value) {
        account = value;
        avatar = account!.data!.user!.avatar!;
        accessToken = account!.data!.accessToken;
      },
    );
    fetchUniversityMajors(accessToken);
    timer = Timer.periodic(const Duration(seconds: 2),
        (Timer t) => fetchUniversityMajors(accessToken));
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  static Future<String?> getAccessToken() async {
    return await Sharedpreferenceshelper.getAccessToken();
  }

  Future<Info?> getInfo() async {
    Info? userInfo = await Sharedpreferenceshelper.getInfo();
    return userInfo;
  }

  Future<void> fetchUniversityMajors(String? token) async {
    if (token != null) {
      final responseUniMajor = await http.get(
        Uri.parse(
            'https://uaportal.online/api/v1/follow/university/major/list?year=2024'),
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

  void reorderData(int oldIndex, int newIndex) async {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = universityList.removeAt(oldIndex);
      universityList.insert(newIndex, item);
    });

    List<Map<String, dynamic>> updatedList = [];
    for (int i = 0; i < universityList.length; i++) {
      updatedList.add({
        "indexOfFollow": i + 1, // index mới sau khi reorder
        "universityMajorId": universityList[i]['universityMajorId'],
      });
    }

    await updateOrderAPI(updatedList);
  }

  Future<void> updateOrderAPI(List<Map<String, dynamic>> data) async {
    String? token = await getAccessToken();
    if (token != null) {
      final response = await http.put(
        Uri.parse(
            'https://uaportal.online/api/v1/follow/university/major/list'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        print('Cập nhật thứ tự thành công');
      } else {
        print('Thất bại: ${response.statusCode}');
      }
    } else {
      print('Token is null');
    }
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
            onTap: () {
              showModalBottomSheet<void>(
                context: context,
                builder: (BuildContext context) {
                  return Container(
                    height: 200,
                    color: const Color.fromARGB(255, 255, 255, 255),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Container(
                            margin: const EdgeInsets.symmetric(
                              vertical: 24,
                            ),
                            child: TextButton(
                              onPressed: () {
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return const AccountScreen();
                                    },
                                  ),
                                );
                              },
                              child: const Text(
                                'Quản lý thông tin',
                              ),
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(vertical: 24),
                            child: TextButton(
                              onPressed: () => _dialogBuilder(context),
                              child: const Text(
                                'Đăng xuất',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            child: avatar != "" ? CircleAvatar(
              backgroundImage: NetworkImage(avatar!),
            ) : CircleAvatar(backgroundImage: AssetImage("assets/student.png"),),
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
          ? Center(
              child: universityList.isEmpty
                  ? const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.info_outline,
                          size: 50,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Bạn chưa theo dõi ngành học nào hết.',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    )
                  : const CircularProgressIndicator(),
            )
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

Future<void> _dialogBuilder(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text(
          'Bạn có chắc chắn muốn đăng xuất ?',
        ),
        actions: <Widget>[
          TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            child: const Text('Yes'),
            onPressed: () {
              // Navigator.of(context).pop();
              Sharedpreferenceshelper.removeInfo();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (context) {
                    return const LoginPage();
                  },
                ),
                (route) => false,
              );
              print('OK');
            },
          ),
          TextButton(
            style: TextButton.styleFrom(
              textStyle: Theme.of(context).textTheme.labelLarge,
            ),
            child: const Text('No'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
