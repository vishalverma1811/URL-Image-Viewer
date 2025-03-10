import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:html' as html;
import 'package:flutter_widget_from_html_core/flutter_widget_from_html_core.dart';
import 'package:fwfh_cached_network_image/fwfh_cached_network_image.dart';

void main() {
  runApp(const MyApp());
}

/// The main application widget.
///
/// This widget initializes the app and sets up the theme and home page.
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return ScreenUtilInit(
      designSize: Size(size.width, size.height),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Image Viewer',
          theme: ThemeData(
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: Colors.white,
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              titleTextStyle: TextStyle(
                color: Colors.black,
                fontSize: 0.02.sh,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          home: const HomePage(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

/// The home page of the application.
///
/// This page allows users to input an image URL, load the image, and view it.
/// It also supports fullscreen mode and includes a floating action button for
/// additional controls.
class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  /// The URL of the image to display.
  String imageUrl = '';

  /// Controller for the URL input field.
  final TextEditingController urlController = TextEditingController();

  /// Tracks whether the app is in fullscreen mode.
  bool isFullScreen = false;

  /// Key for form validation.
  final formKey = GlobalKey<FormState>();

  /// Key for controlling the ExpandableFab state.
  final expandableFabKey = GlobalKey<ExpandableFabState>();

  /// Tracks whether the image is currently loading.
  bool isLoading = false;

  @override
  void dispose() {
    urlController.dispose();
    super.dispose();
  }

  /// Toggles the browser's fullscreen mode.
  ///
  /// If the app is not in fullscreen mode, it enters fullscreen mode.
  /// Otherwise, it exits fullscreen mode.
  void toggleFullScreen() {
    final element = html.document.documentElement;
    if (html.document.fullscreenElement == null) {
      element?.requestFullscreen();
      setState(() => isFullScreen = true);
    } else {
      html.document.exitFullscreen();
      setState(() => isFullScreen = false);
    }
  }

  /// Loads the image from the provided URL.
  ///
  /// Validates the URL input and simulates a network request to load the image.
  /// If successful, the image is displayed; otherwise, an error is shown.
  void handleImageLoad() async {
    if (formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      try {
        // Simulate a network request (replace with actual image loading logic).
        await Future.delayed(const Duration(seconds: 1));

        setState(() {
          imageUrl = urlController.text;
        });

        // Add double-tap event listener to the image.
        final imgElement = html.document.querySelector('img');
        if (imgElement != null) {
          imgElement.onDoubleClick.listen((event) => toggleFullScreen());
        }
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'URL Image Viewer',
          style: TextStyle(
              color: Colors.black,
              fontSize: 0.04.sh,
              fontWeight: FontWeight.w700),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(0.02.sh),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              // URL input field
              Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: TextFormField(
                      controller: urlController,
                      decoration: InputDecoration(
                        hintText: 'Enter image URL',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(0.02.sh),
                        ),
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => urlController.clear(),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a URL';
                        }
                        return null;
                      },
                      onFieldSubmitted: (value) => handleImageLoad(),
                    ),
                  ),
                  SizedBox(width: 0.02.sh),
                  Expanded(
                    flex: 1,
                    child: SizedBox(
                      height: 0.06.sh,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : () => handleImageLoad(),
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 0.02.sw, vertical: 0.01.sh),
                          backgroundColor: Colors.blueGrey,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(0.02.sh),
                          ),
                        ),
                        child: isLoading
                            ? CircularProgressIndicator(
                              color: Colors.black,
                              strokeWidth: 2.w,
                            )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Load',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 0.02.sh,
                                        fontWeight: FontWeight.w700),
                                  ),
                                  SizedBox(
                                    width: 0.01.sw,
                                  ),
                                  const Icon(
                                    Icons.arrow_forward,
                                    color: Colors.white,
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),
                ],
              ),
              // Image display area
              Expanded(
                child: Center(
                  child: imageUrl.isEmpty
                      ? Text(
                          'No image loaded',
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 0.02.sh,
                              fontWeight: FontWeight.w700),
                        )
                      : GestureDetector(
                          onDoubleTap: () => toggleFullScreen(),
                          child: Card(
                            elevation: 8,
                            margin: const EdgeInsets.all(16),
                            child: HtmlWidget(
                              '<img src="$imageUrl" alt="Loaded Image" />',
                              factoryBuilder: () => MyWidgetFactory(),
                              onLoadingBuilder:
                                  (context, element, loadingProgress) => Center(
                                child: CircularProgressIndicator(
                                  color: Colors.amber,
                                ),
                              ),
                              onErrorBuilder: (context, element, error) {
                                return Center(
                                  child: Text(
                                    'Error in loading image',
                                    style: TextStyle(
                                        color: Colors.red, fontSize: 0.02.sh),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: ExpandableFab(
        key: expandableFabKey,
        distance: 0.12.sh,
        overlayStyle: ExpandableFabOverlayStyle(
          blur: 3,
          color: Colors.black.withOpacity(0.3),
        ),
        openButtonBuilder: FloatingActionButtonBuilder(
          size: 0.18.sh,
          builder: (BuildContext context, void Function()? onPressed,
              Animation<double>? progress) {
            return FloatingActionButton(
              backgroundColor: Colors.blueGrey,
              heroTag: null,
              onPressed: onPressed,
              child: const Icon(
                Icons.add,
                color: Colors.white,
              ),
            );
          },
        ),
        closeButtonBuilder: FloatingActionButtonBuilder(
          size: 50,
          builder: (BuildContext context, void Function()? onPressed,
              Animation<double>? progress) {
            return FloatingActionButton(
              backgroundColor: Colors.blueGrey,
              heroTag: null,
              onPressed: onPressed,
              child: const Icon(Icons.close, color: Colors.white),
            );
          },
        ),
        children: [
          FloatingActionButton.small(
            heroTag: null,
            backgroundColor: Colors.blueGrey,
            child: const Icon(
              Icons.fullscreen,
              color: Colors.white,
            ),
            onPressed: () {
              if (!isFullScreen) {
                toggleFullScreen();
              }
              expandableFabKey.currentState?.toggle();
            },
          ),
          FloatingActionButton.small(
            heroTag: null,
            backgroundColor: Colors.blueGrey,
            child: const Icon(
              Icons.fullscreen_exit,
              color: Colors.white,
            ),
            onPressed: () {
              if (isFullScreen) {
                toggleFullScreen();
              }
              expandableFabKey.currentState?.toggle();
            },
          ),
        ],
      ),
    );
  }
}

/// A custom widget factory for rendering HTML with cached network images.
///
/// This factory integrates with the `flutter_widget_from_html_core` package
/// to support cached network images.
class MyWidgetFactory extends WidgetFactory with CachedNetworkImageFactory {}