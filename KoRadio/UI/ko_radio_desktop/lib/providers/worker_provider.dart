

import 'package:ko_radio_desktop/models/worker.dart';

import 'package:ko_radio_desktop/providers/base_provider.dart';


class WorkerProvider extends BaseProvider<Worker>{
  WorkerProvider(): super("Worker");

  @override
  Worker fromJson(data) {
    return Worker.fromJson(data);
  }


    
}

  

