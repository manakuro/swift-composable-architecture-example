//
//  ContentView.swift
//  ComposableArchirectureExample
//
//  Copyright © 2020 manato. All rights reserved.
//

import Combine
import SwiftUI
import ComposableArchitecture

struct Todo: Equatable, Identifiable {
  var id: UUID
  var description = ""
  var isComplete = false
}

enum TodoAction: Equatable {
  case checkboxTapped
  case textFieldChanged(String)
}

struct TodoEnvironment {}

let todoReducer = Reducer<Todo, TodoAction, TodoEnvironment> { state, action, environment in
  switch action {
  case .checkboxTapped:
    state.isComplete.toggle()
    return .none
  case .textFieldChanged(let text):
    state.description = text
    return .none
  }
}

struct AppState: Equatable {
  var todos: [Todo] = []
}

enum AppAction: Equatable {
  case addButtonTapped
  case todo(index: Int, action: TodoAction)
  case todoDelayCompleted
}

struct AppEnvironment {
  var mainQueue: AnySchedulerOf<DispatchQueue>
  var uuid: () -> UUID
}

let appReducer = Reducer<AppState, AppAction, AppEnvironment>.combine(
  todoReducer.forEach(
    state: \AppState.todos,
    action: /AppAction.todo(index:action:),
    environment: { _ in TodoEnvironment() }
  ),
  Reducer { state, action, environment in
    switch action {
    case .addButtonTapped:
      state.todos.insert(Todo(id: environment.uuid()), at: 0)
      return .none
      
    case .todo(index: _, action: .checkboxTapped):
      struct CancelDelayId: Hashable {}
      
      return Effect(value: AppAction.todoDelayCompleted)
        .debounce(id: CancelDelayId(), for: 1, scheduler: environment.mainQueue)
      
    case .todoDelayCompleted:
      state.todos = state.todos
        .enumerated()
        .sorted { lhs, rhs in
          (!lhs.element.isComplete && rhs.element.isComplete)
            || lhs.offset < rhs.offset
      }.map(\.element)
      
      return .none
      
    case .todo(index: let index, action: let action):
      return .none
    }
  }
).debug()

struct ContentView: View {
  let store: Store<AppState, AppAction>
  
  var body: some View {
    NavigationView {
      WithViewStore(self.store) { viewStore in
        List {
          ForEachStore(
            self.store.scope(
              state: \.todos,
              action: AppAction.todo(index:action:)
            ),
            content: TodoView.init(store:)
          )
        }
        .navigationBarTitle("Todos")
        .navigationBarItems(trailing: Button("Add") {
          viewStore.send(.addButtonTapped)
        })
      }
    }
  }
}

struct TodoView: View {
  let store: Store<Todo, TodoAction>
  var body: some View {
    WithViewStore(self.store) { viewStore in
      HStack {
        Button(action: {
          viewStore.send(.checkboxTapped)
        }) {
          Image(systemName: viewStore.isComplete ? "checkmark.square" : "square")
        }.buttonStyle(PlainButtonStyle())
        
        TextField(
          "Untitled todo",
          text: viewStore.binding(
            get: \.description,
            send: TodoAction.textFieldChanged
          )
        )
      }.foregroundColor(viewStore.isComplete ? .gray : nil)
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
        environment: AppEnvironment(
          mainQueue: DispatchQueue.main.eraseToAnyScheduler(),
          uuid: UUID.init
        )
      )
    )
  }
}
