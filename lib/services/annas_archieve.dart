// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:dio/dio.dart';
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart' as dom;
import 'dart:convert';

// ====================================================================
// DATA MODELS
// ====================================================================

class BookData {
  final String title;
  final String? author;
  final String? thumbnail;
  final String link;
  final String md5;
  final String? publisher;
  final String? info;

  BookData(
      {required this.title,
      this.author,
      this.thumbnail,
      required this.link,
      required this.md5,
      this.publisher,
      this.info});
}

class BookInfoData extends BookData {
  String? mirror;
  final String? description;
  final String? format;

  BookInfoData(
      {required super.title,
      required super.author,
      required super.thumbnail,
      required super.publisher,
      required super.info,
      required super.link,
      required super.md5,
      required this.format,
      required this.mirror,
      required this.description});
}

// ====================================================================
// ANNA'S ARCHIVE SERVICE (ALL FIXES APPLIED)
// ====================================================================

class AnnasArchieve {
  // List of mirrors to try in order
  static const List<String> mirrors = [
    "https://annas-archive.li",
    "https://annas-archive.se",
    "https://annas-archive.org",
    "https://annas-archive.pm",
    "https://annas-archive.in"
  ];

  final Dio dio = Dio();

  Map<String, dynamic> defaultDioHeaders = {
    "user-agent":
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/128.0.0.0 Safari/537.36",
  };

  String getMd5(String url) {
    // Handling full URLs from different mirrors
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      return pathSegments.isNotEmpty ? pathSegments.last : '';
    } catch (e) {
      return '';
    }
  }

  String getFormat(String info) {
    final infoLower = info.toLowerCase();
    if (infoLower.contains('pdf')) {
      return 'pdf';
    } else if (infoLower.contains('cbr')) {
      return "cbr";
    } else if (infoLower.contains('cbz')) {
      return "cbz";
    }
    return "epub";
  }

  // Helper function to safely parse potential NaN/Infinity
  dynamic _safeParse(dynamic value) {
    if (value is String) {
      if (value.toLowerCase() == 'nan' || value.toLowerCase() == 'infinity') {
        return null;
      }
      return value;
    }
    return value;
  }

  // --------------------------------------------------------------------
  // _parser FUNCTION
  // --------------------------------------------------------------------
  List<BookData> _parser(resData, String fileType, String currentBaseUrl) {
    var document = parse(resData.toString());

    var bookContainers =
        document.querySelectorAll('div.flex.pt-3.pb-3.border-b');

    List<BookData> bookList = [];

    for (var container in bookContainers) {
      final mainLinkElement =
          container.querySelector('a.line-clamp-\\[3\\].js-vim-focus');
      final thumbnailElement = container.querySelector('a[href^="/md5/"] img');

      if (mainLinkElement == null ||
          mainLinkElement.attributes['href'] == null) {
        continue;
      }

      final String title = mainLinkElement.text.trim();
      final String link = currentBaseUrl + mainLinkElement.attributes['href']!;
      final String md5 = getMd5(mainLinkElement.attributes['href']!);
      final String? thumbnail = thumbnailElement?.attributes['src'];

      dom.Element? authorLinkElement = mainLinkElement.nextElementSibling;
      dom.Element? publisherLinkElement = authorLinkElement?.nextElementSibling;

      if (authorLinkElement?.attributes['href']?.startsWith('/search?q=') !=
          true) {
        authorLinkElement = null;
      }
      if (publisherLinkElement?.attributes['href']?.startsWith('/search?q=') !=
          true) {
        publisherLinkElement = null;
      }

      final String? authorRaw = authorLinkElement?.text.trim();
      final String? author = (authorRaw != null && authorRaw.contains('icon-'))
          ? authorRaw.split(' ').skip(1).join(' ').trim()
          : authorRaw;

      final String? publisher = publisherLinkElement?.text.trim();

      final infoElement = container.querySelector('div.text-gray-800');
      final String? info = infoElement?.text.trim();

      final bool hasMatchingFileType = fileType.isEmpty
          ? (info?.contains(
                  RegExp(r'(PDF|EPUB|CBR|CBZ)', caseSensitive: false)) ==
              true)
          : info?.toLowerCase().contains(fileType.toLowerCase()) == true;

      if (hasMatchingFileType) {
        final BookData book = BookData(
          title: title,
          author: author?.isEmpty == true ? "unknown" : author,
          thumbnail: thumbnail,
          link: link,
          md5: md5,
          publisher: publisher?.isEmpty == true ? "unknown" : publisher,
          info: info,
        );
        bookList.add(book);
      }
    }
    return bookList;
  }
  // --------------------------------------------------------------------

  // --------------------------------------------------------------------
  // _bookInfoParser FUNCTION
  // --------------------------------------------------------------------
  Future<BookInfoData?> _bookInfoParser(
      resData, url, String currentBaseUrl) async {
    var document = parse(resData.toString());
    final main = document.querySelector('div.main-inner');
    if (main == null) return null;

    // --- Mirror Link Extraction ---
    String? mirror;
    final slowDownloadLinks =
        main.querySelectorAll('ul.list-inside a[href*="/slow_download/"]');
    if (slowDownloadLinks.isNotEmpty &&
        slowDownloadLinks.first.attributes['href'] != null) {
      mirror = currentBaseUrl + slowDownloadLinks.first.attributes['href']!;
    }
    // --------------------------------

    // --- Core Info Extraction ---
    final titleElement = main.querySelector('div.font-semibold.text-2xl');
    final authorLinkElement =
        main.querySelector('a[href^="/search?q="].text-base');

    dom.Element? publisherLinkElement = authorLinkElement?.nextElementSibling;
    if (publisherLinkElement?.localName != 'a' ||
        publisherLinkElement?.attributes['href']?.startsWith('/search?q=') !=
            true) {
      publisherLinkElement = null;
    }

    final thumbnailElement = main.querySelector('div[id^="list_cover_"] img');
    final infoElement = main.querySelector('div.text-gray-800');

    dom.Element? descriptionElement;
    final descriptionLabel = main.querySelector(
        'div.js-md5-top-box-description div.text-xs.text-gray-500.uppercase');

    if (descriptionLabel?.text.trim().toLowerCase() == 'description') {
      descriptionElement = descriptionLabel?.nextElementSibling;
    }
    String description = descriptionElement?.text.trim() ?? " ";

    if (titleElement == null) {
      return null;
    }

    final String title = titleElement.text.trim().split('<span')[0].trim();
    final String author = authorLinkElement?.text.trim() ?? "unknown";
    final String? thumbnail = thumbnailElement?.attributes['src'];

    final String publisher = publisherLinkElement?.text.trim() ?? "unknown";
    final String info = infoElement?.text.trim() ?? '';

    return BookInfoData(
      title: title,
      author: author,
      thumbnail: thumbnail,
      publisher: publisher,
      info: info,
      link: url,
      md5: getMd5(url),
      format: getFormat(info),
      mirror: mirror,
      description: description,
    );
  }
  // --------------------------------------------------------------------

  String urlEncoder(
      {required String baseUrl,
      required String searchQuery,
      required String content,
      required String sort,
      required String fileType,
      required bool enableFilters}) {
    searchQuery = searchQuery.replaceAll(" ", "+");
    if (!enableFilters) {
      return '$baseUrl/search?q=$searchQuery';
    }
    return '$baseUrl/search?index=&q=$searchQuery&content=$content&ext=$fileType&sort=$sort';
  }

  /// Generic retry logic for fetching data from mirrors
  /// [operation] is a function that takes a base URL and returns a Future of type T.
  Future<T> _fetchWithFailover<T>(
      Future<T> Function(String baseUrl) operation) async {
    dynamic lastError;

    for (String mirror in mirrors) {
      try {
        // print("Trying mirror: $mirror");
        return await operation(mirror);
      } catch (e) {
        lastError = e;
        // Continue to next mirror
      }
    }

    // If all mirrors fail, rethrow the last error
    if (lastError != null) {
      if (lastError is DioException &&
          lastError.type == DioExceptionType.unknown) {
        throw "socketException";
      }
      throw lastError;
    }
    throw "All mirrors failed";
  }

  Future<List<BookData>> searchBooks(
      {required String searchQuery,
      String content = "",
      String sort = "",
      String fileType = "",
      bool enableFilters = true}) async {
    return _fetchWithFailover<List<BookData>>((baseUrl) async {
      final String encodedURL = urlEncoder(
          baseUrl: baseUrl,
          searchQuery: searchQuery,
          content: content,
          sort: sort,
          fileType: fileType,
          enableFilters: enableFilters);

      final response = await dio.get(encodedURL,
          options: Options(headers: defaultDioHeaders));
      return _parser(response.data, fileType, baseUrl);
    });
  }

  Future<BookInfoData> bookInfo({required String url}) async {
    // Note: 'url' passed here might be a full URL from a search result.
    // Ideally, we should respect the domain in 'url' if it's already absolute.
    // However, if the search result came from a mirror that is now down, we might want to try other mirrors.
    // But usually 'url' here is the specific page for the book.

    // Strategy: Extract the path from the URL and try it on all mirrors.

    String path;
    try {
      final uri = Uri.parse(url);
      path = uri.path;
    } catch (e) {
      // Fallback or rethrow
      throw "Invalid URL";
    }

    return _fetchWithFailover<BookInfoData>((baseUrl) async {
      final fullUrl = "$baseUrl$path";
      final response =
          await dio.get(fullUrl, options: Options(headers: defaultDioHeaders));
      BookInfoData? data =
          await _bookInfoParser(response.data, fullUrl, baseUrl);
      if (data != null) {
        return data;
      } else {
        throw 'unable to get data';
      }
    });
  }

  /// Fetches download links directly from a slow_download URL without using WebView
  /// Returns a list of download mirror links after waiting 8 seconds
  Future<List<String>> fetchDownloadLinks(String slowDownloadUrl) async {
    try {
      // Wait 8 seconds (simulating the server-side wait time)
      await Future.delayed(const Duration(seconds: 8));

      // Fetch the slow_download page
      final response = await dio.get(
        slowDownloadUrl,
        options: Options(headers: defaultDioHeaders),
      );

      // Parse the HTML
      var document = parse(response.data.toString());

      // Try to extract the download link from the page
      // Method 1: Look for the main download link in the paragraph
      final paragraphLink =
          document.querySelector('p.mb-4.text-xl.font-bold a');
      if (paragraphLink != null && paragraphLink.attributes['href'] != null) {
        return [paragraphLink.attributes['href']!];
      }

      // Method 2: Look for IPFS/mirror links in the list
      final mirrorLinks = document.querySelectorAll('ul li a');
      if (mirrorLinks.isNotEmpty) {
        return mirrorLinks
            .where((link) => link.attributes['href'] != null)
            .map((link) => link.attributes['href']!)
            .toList();
      }

      // If no links found, throw error
      throw 'No download links found on the page';
    } catch (e) {
      // If direct fetch fails, rethrow to allow fallback to WebView
      rethrow;
    }
  }
}
