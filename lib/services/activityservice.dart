import 'dart:async';
import 'dart:convert';
import 'model/activity.dart';
import 'package:http/http.dart' as http;

class ActivityService {
  StreamController<Activity>? _activities;
  Stream<Activity>? activityStream;
  final ignoredStream = StreamController<String>();

  // Stream<String>? ignoredStream;
  Timer? periodicRequest;

  ActivityService() {
    _activities = StreamController<Activity>();
    activityStream = _activities?.stream;
  }

  startStream({final String? filter}) async {
    print('starting stream');
    await getActivity(filter);
    periodicRequest?.cancel();
    periodicRequest = Timer.periodic(
      Duration(seconds: 10),
      (timer) async {
        await getActivity(filter);
      },
    );
  }

  Future<void> getActivity(String? filter) async {
    final activityResponse = await http.get(Uri.parse('https://www.boredapi.com/api/activity'));
    final activity = Activity.fromJson(jsonDecode(activityResponse.body));
    if (filter != null) {
      if (activity.activity!.toLowerCase().contains(filter.toLowerCase())) {
        _activities?.add(activity);
      } else {
        ignoredStream.add(activity.activity!);
      }
    } else {
      _activities?.add(activity);
    }

    print(activity);
  }

  stopStream() {
    periodicRequest?.cancel();
  }
}
