class Info {
  int? status;
  String? message;
  Data? data;

  Info({
    this.status,
    this.message,
    this.data,
  });

  // From JSON
  factory Info.fromJson(Map<String, dynamic>? json) {
    if (json == null) return Info();
    return Info(
      status: json['status'],
      message: json['message'],
      data: json['data'] != null ? Data.fromJson(json['data']) : null,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data?.toJson(),
    };
  }

  @override
  String toString() {
    // TODO: implement toString
    return data.toString();
  }
}

class Data {
  String? accessToken;
  String? refreshToken;
  User? user;
  UserInfo? userInfo;

  Data({
    this.accessToken,
    this.refreshToken,
    this.user,
    this.userInfo,
  });

  // From JSON
  factory Data.fromJson(Map<String, dynamic>? json) {
    if (json == null) return Data();
    return Data(
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      userInfo:
          json['userInfo'] != null ? UserInfo.fromJson(json['userInfo']) : null,
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'user': user?.toJson(),
      'userInfo': userInfo?.toJson(),
    };
  }
}

class User {
  int? id;
  String? email;
  String? username;
  String? avatar;
  String? role;

  User({
    this.id,
    this.email,
    this.username,
    this.avatar,
    this.role,
  });

  // From JSON
  factory User.fromJson(Map<String, dynamic>? json) {
    if (json == null) return User();
    return User(
      id: json['id'],
      email: json['email'],
      username: json['username'],
      avatar: json['avatar'],
      role: json['role'],
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'avatar': avatar,
      'role': role,
    };
  }
}

class UserInfo {
  String? firstName;
  String? middleName;
  String? lastName;
  String? phone;
  String? gender;
  String? specificAddress;
  String? educationLevel;
  Province? province;
  District? district;
  Ward? ward;
  String? birthday;

  UserInfo({
    this.firstName,
    this.middleName,
    this.lastName,
    this.phone,
    this.gender,
    this.specificAddress,
    this.educationLevel,
    this.province,
    this.district,
    this.ward,
    this.birthday,
  });

  // From JSON
  factory UserInfo.fromJson(Map<String, dynamic>? json) {
    if (json == null) return UserInfo();
    return UserInfo(
      firstName: json['firstName'],
      middleName: json['middleName'],
      lastName: json['lastName'],
      phone: json['phone'],
      gender: json['gender'],
      specificAddress: json['specificAddress'],
      educationLevel: json['educationLevel'],
      province:
          json['province'] != null ? Province.fromJson(json['province']) : null,
      district:
          json['district'] != null ? District.fromJson(json['district']) : null,
      ward: json['ward'] != null ? Ward.fromJson(json['ward']) : null,
      birthday: json['birthday'],
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'middleName': middleName,
      'lastName': lastName,
      'phone': phone,
      'gender': gender,
      'specificAddress': specificAddress,
      'educationLevel': educationLevel,
      'province': province?.toJson(),
      'district': district?.toJson(),
      'ward': ward?.toJson(),
      'birthday': birthday,
    };
  }
}

class Province {
  int? id;
  String? name;
  String? region;

  Province({
    this.id,
    this.name,
    this.region,
  });

  // From JSON
  factory Province.fromJson(Map<String, dynamic>? json) {
    if (json == null) return Province();
    return Province(
      id: json['id'],
      name: json['name'],
      region: json['region'],
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'region': region,
    };
  }
}

class District {
  int? id;
  String? name;

  District({
    this.id,
    this.name,
  });

  // From JSON
  factory District.fromJson(Map<String, dynamic>? json) {
    if (json == null) return District();
    return District(
      id: json['id'],
      name: json['name'],
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class Ward {
  int? id;
  String? name;

  Ward({
    this.id,
    this.name,
  });

  // From JSON
  factory Ward.fromJson(Map<String, dynamic>? json) {
    if (json == null) return Ward();
    return Ward(
      id: json['id'],
      name: json['name'],
    );
  }

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}
