//
//  ContentView.swift
//  ComposableArchirectureExample
//
//  Copyright © 2020 manato. All rights reserved.
//

import SwiftUI
import ComposableArchitecture

struct Todo: Equatable, Identifiable {
  var id: UUID
  var description = ""
  var isComplete = false
}

struct AppState: Equatable {
  var todos: [Todo]
}

enum AppAction {
  case todoCheckboxTapped(index: Int)
  case todoTextFieldChanged(index: Int, text: String)
}

struct AppEnvironment {}

let appReducer = Reducer<AppState, AppAction, AppEnvironment> { state, action, environment in
  switch action {
    
  case .todoCheckboxTapped(index: let index):
    state.todos[index].isComplete.toggle()
    return .none
  case .todoTextFieldChanged(index: let index, text: let text):
    state.todos[index].description = text
    return .none
  }
}.debug()

struct ContentView: View {
  let store: Store<AppState, AppAction>
  
  var body: some View {
    NavigationView {
      WithViewStore(self.store) { viewStore in
        List {
          ForEach(Array(viewStore.todos.enumerated()), id: \.element.id) { index, todo in
            HStack {
              Button(action: {
                viewStore.send(.todoCheckboxTapped(index: index))
              }) {
                Image(systemName: todo.isComplete ? "checkmark.square" : "square")
              }.buttonStyle(PlainButtonStyle())
              
              TextField(
                "Untitled todo",
                text: viewStore.binding(
                  get: { $0.todos[index].description },
                  send: { .todoTextFieldChanged(index: index, text: $0) }
                )
              )
            }.foregroundColor(todo.isComplete ? .gray : nil)
          }
        }.navigationBarTitle("Todos")
      }
    }
  }
}

struct ContentView_Previews: PreviewProvider {
  static var previews: some View {
    ContentView(
      store: Store(
        initialState: AppState(todos: [
          Todo(id: UUID(), description: "Task1", isComplete: false),
          Todo(id: UUID(), description: "Task2", isComplete: false),
          Todo(id: UUID(), description: "Task3", isComplete: true),
        ]),
        reducer: appReducer,
        environment: AppEnvironment()
      )
    )
  }
}
