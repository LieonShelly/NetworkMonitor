import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
      
        let controller = window?.rootViewController as! FlutterViewController
        let imageChannel = FlutterMethodChannel(name: "com.ltapp.image_processor", binaryMessenger: controller.binaryMessenger)
        imageChannel.setMethodCallHandler { call, result in
            if call.method == "processIcon" {
                guard let args = call.arguments as? [String: Any], let flutterData = args["imageData"] as? FlutterStandardTypedData else {
                    result(FlutterError(code: "INVALID_ARGS", message: "Image data is missing", details: nil))
                    return
                }
                DispatchQueue.global(qos: .userInitiated).async {
                    let imageData = flutterData.data
                    guard let uiimage = UIImage(data: imageData) else {
                        DispatchQueue.main.async {
                            result(FlutterError(code: "DECODE_ERROR", message: "Cannot decode image", details: nil))
                        }
                        return
                    }
                    if let processedImage = MetalImageProcessor.shared.processSync(uiimage, thickness: 4) {
                        if let pngData = processedImage.pngData() {
                            DispatchQueue.main.async {
                                result(pngData)
                            }
                        } else {
                            DispatchQueue.main.async {
                                result(FlutterError(code: "ENCODE_ERROR", message: "Cannot encode result", details: nil))
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            result(FlutterError(code: "PROCESS_ERROR", message: "Metal processing failed", details: nil))
                        }
                    }
                }
            } else {
                result(FlutterMethodNotImplemented)
            }
            
        }
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
    
