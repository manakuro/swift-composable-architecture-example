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
  let scheduler = DispatchQueue.testScheduler
  
  func testCompletingTodo() {
    let store = TestStore(
      initialState: AppState(todos: [
        Todo(id: UUID(), description: "Task1", isComplete: false),
      ]),
      reducer: appReducer,
      environment: AppEnvironment(
        mainQueue: scheduler.eraseToAnyScheduler(),
        uuid: { fatalError("error") }
      )
    )
    
    store.assert(
      .send(.todo(index: 0, action: .checkboxTapped)) {
        $0.todos[0].isComplete = true
      },
      .do {
        // _ = XCTWaiter.wait(for: [self.expectation(description: "wait")], timeout: 1)
        self.scheduler.advance(by: 1)
      },
      .receive(.todoDelayCompleted)
    )
  }
  
  func testAddTodo() {
    let store = TestStore(
      initialState: AppState(),
      reducer: appReducer,
      environment: AppEnvironment(
        mainQueue: scheduler.eraseToAnyScheduler(),
        uuid: { UUID(uuidString: "00000000-0000-0000-0000-000000000000")! }
      )
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
  
  func testTodoSorting() {
    let store = TestStore(
      initialState: AppState(todos: [
        Todo(id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!, description: "Milk", isComplete: false),
        Todo(id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!, description: "Eggs", isComplete: false),
      ]),
      reducer: appReducer,
      environment: AppEnvironment(
        mainQueue: scheduler.eraseToAnyScheduler(),
        uuid: { fatalError("error") }
      )
    )
    
    store.assert(
      .send(.todo(index: 0, action: .checkboxTapped)) {
        $0.todos[0].isComplete = true
      },
      .do {
        self.scheduler.advance(by: 1)
      },
      .receive(.todoDelayCompleted) {
         $0.todos.swapAt(0, 1)
      }
    )
  }
  
  func testTodoSorting_Cancellation() {
    let store = TestStore(
      initialState: AppState(todos: [
        Todo(id: UUID(uuidString: "00000000-0000-0000-0000-000000000000")!, description: "Milk", isComplete: false),
        Todo(id: UUID(uuidString: "00000000-0000-0000-0000-000000000001")!, description: "Eggs", isComplete: false),
      ]),
      reducer: appReducer,
      environment: AppEnvironment(
        mainQueue: scheduler.eraseToAnyScheduler(),
        uuid: { fatalError("error") }
      )
    )
    
    store.assert(
      .send(.todo(index: 0, action: .checkboxTapped)) {
        $0.todos[0].isComplete = true
      },
      .do {
        self.scheduler.advance(by: 0.5)
      },
      .send(.todo(index: 0, action: .checkboxTapped)) {
        $0.todos[0].isComplete = false
      },
      .do {
        self.scheduler.advance(by: 1)
      },
      .receive(.todoDelayCompleted)
    )
  }
}
