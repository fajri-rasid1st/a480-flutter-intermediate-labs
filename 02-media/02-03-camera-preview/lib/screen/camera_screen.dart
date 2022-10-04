import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({
    super.key,
    required this.cameras,
  });

  final List<CameraDescription> cameras;

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

/// todo-cycle-01: mixin with WidgetsBindingObserver
class _CameraScreenState extends State<CameraScreen>
    with WidgetsBindingObserver {
  /// todo-camera-02: create a variable to check Camera is initialize or not
  bool _isCameraInitialized = false;

  /// todo-camera-03: create a variable to handle a camera controller
  CameraController? controller;

  /// todo-swith-01: create a variabel to check Camera is Rear camera or not
  bool _isRearCameraSelected = true;

  /// todo-camera-04: create a function to handle initializing camera
  void onNewCameraSelected(CameraDescription cameraDescription) async {
    /// todo-camera-05: instantiating the camera controller and disposing the previous one
    final previousCameraController = controller;
    final cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.medium,
    );

    await previousCameraController?.dispose();

    /// todo-camera-06: update the new controller
    if (mounted) {
      setState(() {
        controller = cameraController;
      });
    }

    /// todo-camera-07: Update UI if controller updated
    cameraController.addListener(() {
      if (mounted) setState(() {});
    });

    /// todo-camera-08: Initialize controller
    try {
      await cameraController.initialize();
    } on CameraException catch (e) {
      print('Error initializing camera: $e');
    }

    /// todo-camera-09: Update the Boolean
    if (mounted) {
      setState(() {
        _isCameraInitialized = controller!.value.isInitialized;
      });
    }
  }

  @override
  void initState() {
    /// todo-cycle-02: observe the cycle
    WidgetsBinding.instance.addObserver(this);

    /// todo-camera-10: run onNewCameraSelected in setState method and inject with rear camera
    onNewCameraSelected(widget.cameras.first);

    super.initState();
  }

  @override
  void dispose() {
    /// todo-cycle-04: don't forget to remove the observer
    WidgetsBinding.instance.removeObserver(this);

    /// todo-camera-12: don't forget to dispose the controller
    controller?.dispose();
    super.dispose();
  }

  /// todo-cycle-03: handle the app cycle
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = controller;

    // App state changed before we got the chance to initialize.
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      // Free up memory when camera not active
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      // Reinitialize the camera with same properties
      onNewCameraSelected(cameraController.description);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData.dark(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Ambil Gambar"),
          actions: [
            IconButton(
              onPressed: () => _onCameraSwitch(),
              icon: const Icon(Icons.cameraswitch),
            ),
          ],
        ),
        body: Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              /// todo-camera-11: show the camera view
              _isCameraInitialized
                  ? CameraPreview(controller!)
                  : const Center(child: CircularProgressIndicator()),
              Align(
                alignment: const Alignment(0, 0.95),
                child: _actionWidget(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _actionWidget() {
    return FloatingActionButton(
      heroTag: "take-picture",
      tooltip: "Ambil Gambar",
      onPressed: () => _onCameraButtonClick(),
      child: const Icon(Icons.camera_alt),
    );
  }

  Future<void> _onCameraButtonClick() async {
    /// todo-click-01: take a picture and go back to HomeScreen
    final navigator = Navigator.of(context);
    final image = await controller?.takePicture();

    navigator.pop(image);
  }

  void _onCameraSwitch() {
    /// todo-swith-02: set camera to not ready handle anything
    if (widget.cameras.length == 1) return;

    setState(() {
      _isCameraInitialized = false;
    });

    /// todo-swith-03: switch the camera
    onNewCameraSelected(
      widget.cameras[_isRearCameraSelected ? 1 : 0],
    );

    /// todo-swith-04: update the boolean
    setState(() {
      _isRearCameraSelected = !_isRearCameraSelected;
    });
  }
}