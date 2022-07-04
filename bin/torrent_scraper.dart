import 'dart:io';
import 'package:cli_script/cli_script.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart' as dom;

const baseURI = "https://1337x.wtf/";

void main() {
  getResults();
}

void getResults() async {
  stdout.write("Enter a search term: ");
  String searchTerm = stdin.readLineSync()!;
  int index = 0;
  Map torrents = {};
  http.Response response =
      await http.get(Uri.parse(baseURI + 'search/$searchTerm/1/'));
  final body = response.body;
  final html = parse(body);
  final title = html.getElementsByTagName("tbody").forEach((element) {
    for (var element in element.children) {
      final torrentInfo = "$index - ${element.text}";
      final resultLink =
          element.children.first.children.elementAt(1).attributes.values.first;
      final torrentPage = baseURI + resultLink.replaceFirst("/", "");
      torrents[torrentInfo] = torrentPage;
      index++;
    }
  });
  torrents.forEach((key, value) {
    print("$key - $value");
  });
  stdout.write('Select a torrent: ');
  index = int.parse((stdin.readLineSync()!));
  final pickedTorrentName = torrents.entries.elementAt(index).key;
  final pickedTorrentURL = torrents.entries.elementAt(index).value;
  getMagnetLinks(pickedTorrentURL);
  stdout.write("Getting Torrent: $pickedTorrentName");
}

void getMagnetLinks(String movies) async {
  http.Response response = await http.get(Uri.parse(movies));
  dom.Document document = parse(response.body);
  final test = document.getElementsByClassName("container");
  final container = test[2].children;

  var magnetLink = container
      .first
      .children
      .last
      .children
      .first
      .children
      .last
      .children
      .first
      .children
      .first
      .children
      .first
      .firstChild!
      .attributes['href'];

  run('webtorrent', args: {'$magnetLink --vlc'}, runInShell: true);
  Future.delayed((Duration(seconds: 10)), () {
    run('vlc', args: {'http://localhost:8000/0/'}, runInShell: true);
  });
}
