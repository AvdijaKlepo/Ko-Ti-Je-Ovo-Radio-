

import 'package:ko_radio_mobile/models/employee_task.dart';
import 'package:ko_radio_mobile/providers/base_provider.dart';

class EmployeeTaskProvider extends BaseProvider<EmployeeTask>{

  EmployeeTaskProvider(): super("EmployeeTask");

  @override
  EmployeeTask fromJson(data) {
    return EmployeeTask.fromJson(data);
  }

}