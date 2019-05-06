//
//  CoreDataTestCaseTests.swift
//  tba-unit-tests
//
//  Created by Zachary Orr on 11/22/18.
//  Copyright © 2018 The Blue Alliance. All rights reserved.
//

import Foundation

class CoreDataTestCaseTests: CoreDataTestCase {

    func test_contextSaved() {
        let saveExpectation = expectation(description: "Context saved")
        waitForSavedNotification { _,_  in
            saveExpectation.fulfill()
        }
        try! persistentContainer.viewContext.save()
        wait(for: [saveExpectation], timeout: 1.0)
    }

    func test_contextSaved_noSave() {
        let saveExpectation = expectation(description: "Context saved")
        saveExpectation.isInverted = true
        waitForSavedNotification { _,_  in
            saveExpectation.fulfill()
        }
        wait(for: [saveExpectation], timeout: 1.0)
    }

}
