//
//  CameraView.swift
//  Grav_app_simple
//
//  Created by Yoshiyuki Kitaguchi on 2023/02/23.
//


import SwiftUI

struct CameraPage: View {
    
    @ObservedObject var user: User
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var imageData : Data = .init(capacity:0)
    @State var rawImage : Data = .init(capacity:0)
    @State var source:UIImagePickerController.SourceType = .camera

    @State var isActionSheet = true
    @State var isImagePicker = true
    
    var body: some View {
            NavigationView{
                VStack(spacing:0){
                        ZStack{
                            NavigationLink(
                                destination: Imagepicker(show: $isImagePicker, image: $imageData, sourceType: source),
                                isActive:$isImagePicker,
                                label: {
                                    Text("TakePhoto")
                                })
                            VStack{
                                //写真を撮ったらSendDataへ
                                //if imageData.count != 0{
                                if isImagePicker == false{
                                    SendData(user:user)
                            }
                        }
                }
                .navigationBarTitle("", displayMode: .inline)

            }
        .ignoresSafeArea(.all, edges: .top)
        .background(Color.primary.opacity(0.06).ignoresSafeArea(.all, edges: .all))
    }
    
    
}

}