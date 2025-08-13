import 'package:ko_radio_desktop/models/employee_task.dart';
import 'package:ko_radio_desktop/providers/base_provider.dart';

class EmployeeTaskProvider extends BaseProvider<EmployeeTask>{

  EmployeeTaskProvider(): super("EmployeeTask");

  @override
  EmployeeTask fromJson(data) {
    return EmployeeTask.fromJson(data);
  }

}