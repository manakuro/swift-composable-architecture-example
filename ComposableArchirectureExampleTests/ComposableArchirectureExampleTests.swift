//
//  ComposableArchirectureExampleTests.swift
//  ComposableArchirectureExample
//
//  Copyright © 2020 manato. All rights reserved.
//

import ComposableArchitecture
import XCTest
@testable import ComposableArchirectureExample

class TodosTests: XCTestCase {
  func testCompletingTodo() {
    let store = TestStore(
      initialState: AppState(todos: [
        Todo(id: UUID(), description: "Task1", isComplete: false),
        Todo(id: UUID(), description: "Task2", isComplete: false),
        Todo(id: UUID(), description: "Task3", isComplete: true),
      ]),
      reducer: appReducer,
      environment: AppEnvironment(uuid: { fatalError("error") })
    )
    
    store.assert(
      .send(.todo(index: 0, action: .checkboxTapped)) {
        $0.todos[0].isComplete = true
      }
    )
  }
  
  func testAddTodo() {
    let store = TestStore(
      initialState: AppState(),
      reducer: appReducer,
      environment: AppEnvironment(uuid: { UUID(uuidString: "00000000-0000-0000-0000-000000000000")! })
    )
    
    store.assert(
      .send(.addButtonTapped) {
        $0.todos = [
          Todo(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!,
            description: "",
            isComplete: false
          )
        ]
      }
    )
  }
}
