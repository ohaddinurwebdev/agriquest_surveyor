class Permissions {
  Map<String, ProjectPermissions> projects;

  Permissions(this.projects);

  factory Permissions.fromMap(Map<String, dynamic> map) {
    Map<String, ProjectPermissions> permissions = {};
    map.entries.forEach((projectPermissions) {
      ProjectPermissions project =
          ProjectPermissions.fromList(projectPermissions.value);
      if (project.groups.length > 0)
        permissions[projectPermissions.key] = project;
    });

    return Permissions(permissions);
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {};
    projects.entries.forEach((element) {
      map[element.key] = element.value.toList();
    });
    return map;
  }
}

class ProjectPermissions {
  List<GroupPermissions> groups;

  ProjectPermissions(this.groups);

  factory ProjectPermissions.fromList(List<dynamic> list) {
    return ProjectPermissions(list
        .map((groupPermissions) => GroupPermissions.fromMap(groupPermissions))
        .where((element) => element.canSurvey)
        .toList());
  }

  List<Map<String, dynamic>> toList() {
    return groups.map((group) => group.toMap()).toList();
  }
}

class GroupPermissions {
  String groupName;
  String role;

  GroupPermissions({this.groupName, this.role});

  bool get canSurvey => role == 'Surveyor' || role.contains('Admin');

  factory GroupPermissions.fromMap(Map<String, dynamic> map) {
    return GroupPermissions(groupName: map['groupName'], role: map['role']);
  }

  Map<String, String> toMap() {
    return {'groupName': groupName, 'role': role};
  }
}
