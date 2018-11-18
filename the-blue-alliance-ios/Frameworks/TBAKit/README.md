## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

Set up a TBAKit instance (or use the singleton) to make an API call

```swift
func fetchStatusSingleton() {
	TBAKit.sharedKit.apiKey = "abc123"
    let task = TBAKit.sharedKit.fetchStatus { (status, error) in
    	if let error = error {
    		print(error)
    		return
	    }
	    print(status)
    }
}

func fetchStatusInstance() {
	let kit = TBAKit(apiKey: "abc123")
    let task = kit.fetchStatus { (status, error) in
    	if let error = error {
    		print(error)
    		return
	    }
	    print(status)
    }
}
```

## Adding Tests

If you'd like to modify or add a test, the local testing files are in the `data` directory. The local testing files are static JSON responses from API endpoints that are sent to the mocked requests. To name the file, modify the API endpoint name by replacing slashes with underscores and making sure the file is a `.json`

```
URL => https://www.thebluealliance.com/api/v3/team/frc2337/event/2016micmp/status
Filename => team_frc2337_event_2016micmp_status
```

## License

TBAKit is available under the MIT license. See the LICENSE file for more info.
