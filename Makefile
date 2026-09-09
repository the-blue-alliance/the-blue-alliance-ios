# Local entry point. CI runs these same targets.
# Release lanes (TestFlight, App Store, signing) are CI-only, in fastlane/Fastfile.

ROOT    := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
DERIVED := $(ROOT)/DerivedData
RESULTS := $(ROOT)/test_output
PROJECT := the-blue-alliance-ios.xcodeproj
SCHEME  := The Blue Alliance
SECRETS := the-blue-alliance-ios/Secrets.plist
DEVICE  := platform=iOS Simulator,name=iPhone 17 Pro

# Build tool plugins and macros are only trusted through Xcode's UI.
XCARGS  := -skipPackagePluginValidation -skipMacroValidation COMPILER_INDEX_STORE_ENABLE=NO

XCTEST   = xcodebuild test -destination "$(DEVICE)" -derivedDataPath "$(DERIVED)" $(XCARGS)

# Packages are iOS-only, so they build for a simulator instead of `swift test`.
# Absolute paths because the recipe cd's in, and xcodebuild won't overwrite a
# result bundle.
package_test = rm -rf "$(RESULTS)/$(1).xcresult" && cd "$(ROOT)/Packages/$(1)" && \
	$(XCTEST) -scheme "$(1)" -resultBundlePath "$(RESULTS)/$(1).xcresult"

.DEFAULT_GOAL := help

.PHONY: help format lint lint-format lint-deps test test-app test-packages \
	test-mytbakit test-tbautils test-tbaapi test-tbaauth \
	summary new-version secrets icons clean

help: ## Show this help
	@grep -hE '^[a-z][a-z-]*:.*##' $(MAKEFILE_LIST) | sed 's/:.*##/|/' \
		| awk -F'|' '{ printf "  %-15s %s\n", $$1, $$2 }'
	@echo "  new-version     Bump the version. Usage: make new-version BUMP=patch"

format: ## Format Swift files with swift-format
	./scripts/swift-format.sh --fix

lint: lint-format lint-deps ## Run every lint check

lint-format: ## Lint Swift formatting (strict, matches CI)
	./scripts/swift-format.sh --strict

lint-deps: ## Check dependency pins agree across packages
	./scripts/check-dependency-pins.py

test: test-packages test-app ## Run all tests

test-app: ## Run TBAUnitTests, plus TBAAPI and MyTBAKit, in the app scheme
	rm -rf "$(RESULTS)/App.xcresult"
	$(XCTEST) -project "$(PROJECT)" -scheme "$(SCHEME)" -configuration Debug \
		-resultBundlePath "$(RESULTS)/App.xcresult" -disableAutomaticPackageResolution

# xcodebuild refuses to host TBAUtilsTests and TBAAuthTests in the app scheme, so
# those two run on their own. TBAAPI and MyTBAKit are covered by test-app.
test-packages: test-tbautils test-tbaauth ## Run packages the app scheme doesn't cover

test-mytbakit: ## Run MyTBAKit tests
	$(call package_test,MyTBAKit)

test-tbautils: ## Run TBAUtils tests
	$(call package_test,TBAUtils)

test-tbaapi: ## Run TBAAPI tests
	$(call package_test,TBAAPI)

test-tbaauth: ## Run TBAAuth tests
	$(call package_test,TBAAuth)

summary: ## Summarize the last test run
	@for bundle in "$(RESULTS)"/*.xcresult; do ./scripts/test-summary.sh "$$bundle"; done

new-version:
	@set -eu; \
	case "$(BUMP)" in major|minor|patch) ;; \
		*) echo "Usage: make new-version BUMP=major|minor|patch" >&2; exit 1 ;; esac; \
	next=$$(xcrun agvtool what-marketing-version -terse1 \
		| awk -F. -v b="$(BUMP)" '{ \
			if (b == "major") { $$1++; $$2 = 0; $$3 = 0 } \
			else if (b == "minor") { $$2++; $$3 = 0 } \
			else { $$3++ } \
			printf "%d.%d.%d", $$1, $$2, $$3 }'); \
	xcrun agvtool new-marketing-version "$$next"; \
	xcrun agvtool new-version -all 1

secrets: ## Write the TBA_API_KEY env var into Secrets.plist
	@test -n "$$TBA_API_KEY" || { echo "TBA_API_KEY is not set" >&2; exit 1; }
	@/usr/libexec/PlistBuddy -c "Set :tba_api_key $$TBA_API_KEY" "$(SECRETS)"

icons: ## Regenerate the app icon preview assets
	./scripts/generate-app-icon-previews.sh --force

clean: ## Remove build and test output
	rm -rf "$(DERIVED)" "$(RESULTS)" "$(ROOT)/build"
