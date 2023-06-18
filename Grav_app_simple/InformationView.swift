
//
//  Informations.swift
//  CorneaApp
//
//  Created by Yoshiyuki Kitaguchi on 2021/04/18.
//
import SwiftUI

struct Informations: View {
    @ObservedObject var user: User
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var isSaved = false
    @State private var goTakePhoto: Bool = false  //撮影ボタン
    @State private var temp = "" //スキャン結果格納用の変数
    @State private var isScanning = false
    @State private var showAlert = false

    var body: some View {
        VStack {
            Spacer()
            
            Text("診察券番号を下の枠に入力してください")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.purple)
                .padding(.vertical, 20)
                .padding(.horizontal, 40)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.yellow)
                        .shadow(color: .gray, radius: 3, x: 0, y: 2)
                )
            
            TextField("ここに入力", text: $user.id)
                .font(.system(size: 60))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .keyboardType(.numberPad)
                .onChange(of: user.id) { _ in
                    self.user.isSendData = false
                }
            
            Spacer()
            
            Button(action: {
                if user.id.isEmpty {
                    showAlert = true
                } else {
                    goTakePhoto.toggle()
//                    self.presentationMode.wrappedValue.dismiss()
                }
            }) {
                Text("保存")
                    .foregroundColor(Color.white)
                    .font(Font.largeTitle)
            }
            .frame(minWidth:0, maxWidth:CGFloat.infinity, minHeight: 150)
            .background(Color.black)
            .padding()
            .sheet(isPresented: self.$goTakePhoto) {
                CameraPage(user: user)
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("エラー"), message: Text("IDを入力してください"), dismissButton: .default(Text("OK")))
            }
        }
    }
}
