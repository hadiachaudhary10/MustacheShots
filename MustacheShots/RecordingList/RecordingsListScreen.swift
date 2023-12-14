//
//  RecordingsListScreen.swift
//  MustacheShots
//
//  Created by Dev on 13/12/2023.
//

import SwiftUI

struct RecordingsListScreen: View {
  @StateObject var viewModel: RecordingsListViewModel
  var body: some View {
    NavigationStack {
      GeometryReader { geo in
        ScrollView(.vertical) {
          VStack(alignment: .leading) {
            ForEach(0..<viewModel.numberOfShots) { _ in
              HStack {
                Image(systemName: "square.fill")
                  .resizable()
                  .frame(width: geo.size.height/7, height: geo.size.height/7)
                  .padding(.leading)
                  .foregroundColor(Color.imagePlaceholder)
                VStack(alignment: .leading) {
                  Text("Heyy")
                  Spacer()
                  HStack {
                    Text("6:05")
                    Spacer()
                    Button {
                      print("Button tapped")
                    } label: {
                      Image(systemName: "square.and.pencil")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 20, height: 20)
                    }
                  }
                }
                .padding(.all)
                Spacer()
              }
              .frame(height: geo.size.height/6)
              .background(Color.pastelGrey)
              .cornerRadius(10)
              .padding(.horizontal)
            }
          }
        }
        .frame(width: geo.size.width, height: geo.size.height)
      }
      .padding(.top)
      .navigationTitle("Recordings List")
      .navigationBarItems(trailing: NavigationLink(destination: VideoScreen(viewModel: VideoScreenViewModel())) {
        Image(systemName: "plus")
      })
      .toolbarColorScheme(.dark, for: .navigationBar)
      .toolbarBackground(Gradient.blueGrottoGradident, for: .navigationBar)
      .toolbarBackground(.visible, for: .navigationBar)
    }
  }
}

struct RecordingsListScreen_Previews: PreviewProvider {
  static var previews: some View {
    RecordingsListScreen(viewModel: RecordingsListViewModel())
  }
}
