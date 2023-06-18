//
//  ContentView.swift
//  CorneaApp
//
//  Created by Yoshiyuki Kitaguchi on 2021/04/18.
//
//写真Coredata参考サイト：https://tomato-develop.com/swiftui-camera-photo-library-core-data/
//
import SwiftUI
import CoreData

//変数を定義
class User : ObservableObject {
    @Published var date: Date = Date()
    @Published var id: String = ""
    @Published var hashid: String = ""
    @Published var selected_gender: Int = 0
    @Published var selected_side: Int = 0
    @Published var selected_hospital: Int = 0
    @Published var selected_disease: Int = 0
    @Published var free_disease: String = ""
    @Published var ssmixpath: String = "" //JOIR転送用フォルダ
    @Published var gender: [String] = ["", "男", "女"]
    @Published var genderCode: [String] = ["O", "M", "F"]
    @Published var birthdate: String = ""
    @Published var side: [String] = ["", "右", "左"]
    @Published var sideCode: [String] = ["N", "R", "L"]
    @Published var hospitals: [String] = ["", "オリンピア眼科", "大阪大"]
    @Published var hospitalsAbbreviated: [String] = ["", "OLY", "OSK"]
    @Published var hospitalcode: [String] = ["", "1370147", "9900249"]
    @Published var disease: [String] = ["", "甲状腺眼症", "コントロール"]
    @Published var imageNum: Int = 0 //写真の枚数（何枚目の撮影か）
    @Published var isNewData: Bool = false
    @Published var isSendData: Bool = false
    @Published var sourceType: UIImagePickerController.SourceType = .camera //撮影モードがデフォルト
    @Published var equipmentVideo: Bool = true //video or camera 撮影画面のマージ指標変更のため
    }


struct ContentView: View {
    @ObservedObject var user = User()
    @State private var goTakePhoto: Bool = false  //撮影ボタン
    @State private var isPatientInfo: Bool = false  //患者情報入力ボタン
    @State private var forStaff: Bool = false  //スタッフ用画面に移行するボタン

    
    var body: some View {
        VStack(alignment:.center, spacing:0){
            Text("Grav app mini")
                .font(.largeTitle)
                .fontWeight(.heavy)
                .padding(.bottom)
            
            Image("MovieIcon")
                .resizable()
                .scaledToFit()
                .frame(width: 200)
        }
        
        
        
        VStack(alignment:.leading, spacing:-10){
            
            Button(action: {
                //病院番号はアプリを落としても保存されるようにしておく
                self.user.selected_hospital = UserDefaults.standard.integer(forKey: "hospitaldefault")
                self.user.selected_disease = UserDefaults.standard.integer(forKey: "diseasedefault")
                self.isPatientInfo = true /*またはself.show.toggle() */
                
            }) {
                HStack{
                    Image(systemName: "person.text.rectangle")
                    Text("患者情報入力")
                }
                    .foregroundColor(Color.white)
                    .font(Font.largeTitle)
            }
                .frame(minWidth:0, maxWidth:CGFloat.infinity, minHeight: 75)
                .background(Color.black)
                .padding()
            .sheet(isPresented: self.$isPatientInfo) {
                Informations(user: user)
                //こう書いておかないとmissing as ancestorエラーが時々でる
            }
            
            
                
                
                
            //送信するとボタンの色が変わる演出
            if self.user.isSendData {
                Button(action: {
                    self.user.sourceType = UIImagePickerController.SourceType.camera
                    self.user.equipmentVideo = true
                    self.goTakePhoto = true /*またはself.show.toggle() */
                    self.user.isSendData = false //撮影済みを解除
                    ResultHolder.GetInstance().SetMovieUrls(Url: "")  //動画の保存先をクリア
                }) {
                    HStack{
                        Image(systemName: "video")
                        Text("撮影済み")
                    }
                        .foregroundColor(Color.white)
                        .font(Font.largeTitle)
                }
                    .frame(minWidth:0, maxWidth:CGFloat.infinity, minHeight: 75)
                    .background(Color.blue)
                    .padding()
                .sheet(isPresented: self.$goTakePhoto) {
                    CameraPage(user: user)
                }
            } else {
                Button(action: {
                    self.user.sourceType = UIImagePickerController.SourceType.camera
                    self.user.equipmentVideo = true
                    self.goTakePhoto = true /*またはself.show.toggle() */
                    self.user.isSendData = false //撮影済みを解除
                    ResultHolder.GetInstance().SetMovieUrls(Url: "")  //動画の保存先をクリア
                }) {
                    HStack{
                        Image(systemName: "video")
                        Text("撮影")
                    }
                        .foregroundColor(Color.white)
                        .font(Font.largeTitle)
                }
                    .frame(minWidth:0, maxWidth:CGFloat.infinity, minHeight: 75)
                    .background(Color.black)
                    .padding()
                .sheet(isPresented: self.$goTakePhoto) {
                    CameraPage(user: user)
                }
            }
            

            
            Button(action: {
                //病院番号はアプリを落としても保存されるようにしておく
                self.user.selected_hospital = UserDefaults.standard.integer(forKey: "hospitaldefault")
                self.forStaff = true /*またはself.show.toggle() */
                
            }) {
                HStack{
                    Image(systemName: "person.2.badge.gearshape.fill")
                    Text("スタッフ用")
                }
                    .foregroundColor(Color.white)
                    .font(Font.largeTitle)
            }
                .frame(minWidth:0, maxWidth:CGFloat.infinity, minHeight: 75)
                .background(Color.black)
                .padding()
            .sheet(isPresented: self.$forStaff) {
                ForStaff(user: user)
                //こう書いておかないとmissing as ancestorエラーが時々でる
            }
            
            
            
        
            
            
        }
    }
}
