import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutterstreams/services/activityservice.dart';

import '../model/activity.dart';

class StreamViewer extends StatefulWidget {
  const StreamViewer({Key? key}) : super(key: key);

  @override
  State<StreamViewer> createState() => _StreamViewerState();
}

class _StreamViewerState extends State<StreamViewer> {
  final _activityService = ActivityService();
  StreamSubscription<String>? ignoredActivityStream;
  final _textEditingController = TextEditingController();

  @override
  void initState() {
    ignoredActivityStream = _activityService.ignoredStream.stream.listen((event) {
      final snackbar = SnackBar(content: Text('Ignoring ${event}...'));
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(snackbar);
    });
    // TODO: implement initState
    super.initState();
  }

  @override
  Future<void> dispose() async {
    await ignoredActivityStream?.cancel();
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Something to do'),
      ),
      body: ListView(
        children: [
          Container(
            color: Theme.of(context).primaryColor,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(50.0),
                  child: Text(
                    "Let's find something to do.",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headline2,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Card(
                    elevation: 10,
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    fillColor: Colors.white70,
                                    hintText: 'Filter by text here, or just tap search',
                                  ),
                                  controller: _textEditingController,
                                ),
                              ),
                              IconButton(
                                  onPressed: () {
                                    _activityService.startStream(
                                        filter: _textEditingController.text.isNotEmpty
                                            ? _textEditingController.text
                                            : null);
                                  },
                                  icon: Icon(Icons.search))
                            ],
                          ),
                          TextButton(
                            onPressed: () {
                              _activityService.stopStream();
                            },
                            child: Text('STOP STREAM'),
                          )
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          StreamBuilder<Activity>(
              stream: _activityService.activityStream,
              builder: (context, snapshot) {
                return AnimatedSize(
                  duration: Duration(milliseconds: 800),
                  child: AnimatedSwitcher(
                    duration: Duration(seconds: 1),
                    child: snapshot.hasData
                        ? Card(
                            key: Key(snapshot.data!.activity!),
                            child: Column(
                              children: [
                                Text(
                                  snapshot.data!.activity!,
                                  style: TextStyle(fontSize: 30),
                                  textAlign: TextAlign.center,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(32.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        children: [
                                          Icon(Icons.people),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(snapshot.data!.participants!.toString()),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Icon(Icons.attach_money),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              snapshot.data!.price.toString(),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Icon(Icons.accessibility_new),
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: CircularProgressIndicator(
                                                backgroundColor: Colors.grey,
                                                value: snapshot.data!.accessibility!.toDouble()),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          )
                        : WaitingForData(),
                  ),
                );
                return CircularProgressIndicator();
              })
        ],
      ),
    );
  }
}

class WaitingForData extends StatelessWidget {
  const WaitingForData({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Icon(Icons.search_off),
            Text(
              'No tasks yet...',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headline6,
            ),
          ],
        ),
      ),
    );
  }
}
