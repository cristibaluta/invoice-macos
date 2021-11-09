// This file contains the fastlane.tools configuration
// You can find the documentation at https://docs.fastlane.tools
//
// For a list of all available actions, check out
//
//     https://docs.fastlane.tools/actions
//

import Foundation

class Fastfile: LaneFile {
	func betaLane() {
        desc("Push a new beta build to TestFlight")
        incrementBuildNumber(xcodeproj: "Invoices.xcodeproj")
        updateCodeSigningSettings(path: "Invoices.xcodeproj", useAutomaticSigning: true)
        buildApp(scheme: "Invoices", exportTeamId: .userDefined("5NHDC5EV44"))
		uploadToTestflight(username: "cristi.baluta+apple@gmail.com")
	}
}
