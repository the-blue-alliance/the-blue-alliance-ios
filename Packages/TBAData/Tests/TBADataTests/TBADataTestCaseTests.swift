class TBADataTestCaseTests: TBADataTestCase {

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
