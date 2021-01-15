import 'package:flutter/rendering.dart';
import 'package:http/http.dart';
import 'package:http/io_client.dart';

import 'job.dart';
import 'surveyWidgets.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'dart:developer' as developer;

class Database {

  // TODO: make const for final build
  static String SERVER = 'https://192.168.1.13';
  static int PORT = 5000;

  // TODO: image asset paths

  IOClient _ioClient;

  Database() {

    var httpClient = HttpClient();

    // not needed as we now do this globally
    /*
    // allow self-signed certificates
    httpClient.badCertificateCallback =
    ((X509Certificate cert, String host, int port) => true);
    */


    _ioClient = IOClient(httpClient);

  }


  String _generateUrl(String route, int jobNumber) {
    return '$SERVER:$PORT/jobs$route?jobID=$jobNumber';
  }

  Future<Response> _get(String route, int jobNumber) async {
    String url = _generateUrl(route, jobNumber);
    var response = await _ioClient.get(url);
    return response;
  }

  Future<Response> _post(String route, int jobNumber, String data) async {
    String url = _generateUrl(route, jobNumber);
    var response = await _ioClient.post(url,
      headers: {"Content-Type": "application/json"},
      body: data
    );
    return response;
  }

  Future<bool> jobExists(int jobNumber) async {
    var response = await _get('/', jobNumber);
    var info = jsonDecode(response.body);
    return info['exists'];
  }

  Future<Job> getJob(int jobNumber) async {
    var job = Job();
    await job.loadString(_getJobString(jobNumber));
    return job;
  }

  // not perfect but if it aint broke dont fix it
  Future<String> _getJobString(int jobNumber) async {
    //developer.log('Getting job string');

    var response = await _get('/checkout', jobNumber);

    developer.log(response.body);
    return response.body;

  }

  void returnJob(int jobNumber, Map<int, SurveyItemState> data) async {
    var initialJob = await jsonDecode(await _getJobString(jobNumber));

    for (int i = 0; i < initialJob['survey'].length; i++) {
      //initialJob['survey'][i]['result'] = Map<String, dynamic>();
      initialJob['survey'][i]['result']['value'] = data[i].get().text;
      //initialJob['survey'][i]['result']['valid'] = data[i].get().isValid;
    }

    initialJob['complete'] = true;

    await _post('/return', jobNumber, jsonEncode(initialJob));

  }

}