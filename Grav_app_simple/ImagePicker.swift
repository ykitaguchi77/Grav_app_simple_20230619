//
//  ImagePicker.swift
//  CorneaApp
//
//  Created by Yoshiyuki Kitaguchi on 2021/12/03.
//  https://tomato-develop.com/swiftui-how-to-use-camera-and-select-photos-from-library/
//
// movie acquision:
//https://hatsunem.hatenablog.com/entry/2018/12/04/004823
//https://off.tokyo/blog/how-to-access-info-plist/
//https://ichi.pro/swift-uiimagepickercontroller-250133769115456
//正方形動画撮影　https://superhahnah.com/swift-square-av-capture/
import SwiftUI
import UIKit
import AssetsLibrary
import Foundation
import AVKit
import Photos
import AVFoundation

struct Imagepicker : UIViewControllerRepresentable {
    @Binding var show:Bool
    @Binding var image:Data
    @State private var shutter: Bool = false
    
    var sourceType:UIImagePickerController.SourceType
 
    func makeCoordinator() -> Imagepicker.Coodinator {
        
        return Imagepicker.Coordinator(parent: self)
    }
      
    func makeUIViewController(context: UIViewControllerRepresentableContext<Imagepicker>) -> UIImagePickerController {
        
        let controller = UIImagePickerController()
        controller.sourceType = sourceType
        controller.delegate = context.coordinator
        
        //photo, movieモード選択
        //controller.mediaTypes = ["public.image", "public.movie"]
        controller.mediaTypes = ["public.movie"]
        controller.cameraCaptureMode = .video // Default media type .photo vs .video
        controller.videoQuality = .typeHigh
        controller.cameraFlashMode = .off
        controller.cameraDevice = .rear //or front
        controller.allowsEditing = false
        
        //overlay image
        let screenWidth = UIScreen.main.bounds.size.width
        //controller.cameraOverlayView = CircleView(frame: CGRect(x: (screenWidth / 2) - 50, y: (screenWidth / 2) + 25, width: 100, height: 100))
        
        controller.cameraOverlayView = MergeView(frame: CGRect(x: 0, y: 0, width: screenWidth, height: screenWidth*1.5))  //screenheightで定義すると、use_imageに描画が重なってしまいボタンが押せなくなるため小さくした
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<Imagepicker>) {
    }
    
    class Coodinator: NSObject,UIImagePickerControllerDelegate,UINavigationControllerDelegate {

        var parent : Imagepicker
        
        init(parent : Imagepicker){
            self.parent = parent
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            self.parent.show.toggle()
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            
            
            // Check for the media type
            if let mediaType = info[UIImagePickerController.InfoKey.mediaType] as? String {

                if mediaType  == "public.image" {
                    print("Image Selected")
                    
                    let image = info[.originalImage] as! UIImage
                    let data = image.pngData()
                    self.parent.image = data!
                    self.parent.show.toggle()

                    UIImageWriteToSavedPhotosAlbum(image, nil,nil,nil) //カメラロールに保存
                    let cgImage = image.cgImage //CGImageに変換
                    let cropped = cgImage!.cropToSquare()
                    //撮影した画像をresultHolderに格納する
                    let imageOrientation = getImageOrientation()
                    let rawImage = UIImage(cgImage: cropped).rotatedBy(orientation: imageOrientation)
                    ResultHolder.GetInstance().SetImage(index: 0, cgImage: rawImage.cgImage!)
                    ResultHolder.GetInstance().SetMovieUrls(Url: "")
                    //setImage(progress: 0, cgImage: rawImage.cgImage!)
                }

                if mediaType == "public.movie" {
                    print("Video Selected")
                    
                    // get a URL for the selected local file with nil safety
                    guard let mediaUrl = info[UIImagePickerController.InfoKey.mediaURL] as? URL else { return }

                    print(mediaUrl)
                    
                    let tempDirectory: URL = URL(fileURLWithPath: NSTemporaryDirectory())
                    let croppedMovieFileURL: URL = tempDirectory.appendingPathComponent("mytemp2.mov")
                    

                    MovieCropper.exportSquareMovie(sourceURL: mediaUrl, destinationURL: croppedMovieFileURL, fileType: .mov, completion: {
                        // 正方形にクロッピングされた動画をフォトライブラリに保存
                        self.saveMovieToPhotoLibrary(fileURL: croppedMovieFileURL)
                        self.saveToResultHolder(fileURL: croppedMovieFileURL)
                    })
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {

                        self.parent.show.toggle()
                    }
                }
            }
        }
        
        

        func saveMovieToPhotoLibrary(fileURL: URL) {
            //カメラロールに保存
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: fileURL)
            })

        }
        
        //サムネイル切り出し　https://qiita.com/doge_kun55/items/727b5caf100a40739bdf
        //→depricated
        
        
        
        func saveToResultHolder(fileURL: URL){
            //ResultHolderに保存
            ResultHolder.GetInstance().SetMovieUrls(Url: fileURL.absoluteString)
        }
    }
}




class MergeView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.clear
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        if let context = UIGraphicsGetCurrentContext() {
            context.setLineWidth(3.0)
            let width = frame.size.width

//            //Rectangle
//            UIColor.red.set()
//            context.addRect(CGRect(origin:CGPoint(x:0, y:width*27/96), size: CGSize(width:width, height:width)))
//            context.strokePath()
//
//            //Circle
//            UIColor.blue.set()
//            let radius = frame.size.width/2
//            context.addArc(center: CGPoint(x:radius, y:radius*150/96), radius: radius*4/5, startAngle: 0.0, endAngle: .pi * 2.0, clockwise: true)
//            context.strokePath()
            
            //Elllipse
            UIColor.blue.set()
            context.addEllipse(in: CGRect(x:width/5, y:width*37/96, width:width*3/5, height:width*4/5))
            
            context.strokePath()
        }
    }
}
