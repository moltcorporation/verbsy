import SwiftUI

struct MainAppView: View {
    @Binding var selectedTab: Int
    @Binding var showPaywall: Bool
    @Binding var requestedLearnMode: LearnMode?
    @Binding var requestedLearnWordSlug: String?
    @Binding var requestedProfileRoute: ProfileRoute?

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(showPaywall: $showPaywall, requestedRoute: $requestedProfileRoute, openLearn: { selectedTab = 1 })
                .tabItem { Label("Home", systemImage: "house.fill") }
                .tag(0)

            LearnView(requestedMode: $requestedLearnMode, requestedWordSlug: $requestedLearnWordSlug)
                .tabItem { Label("Learn", systemImage: "sparkles") }
                .tag(1)

            ProfileView(showPaywall: $showPaywall, requestedRoute: $requestedProfileRoute)
                .tabItem { Label("You", systemImage: "person.crop.circle") }
                .tag(2)
        }
        .tint(VerbsyDesign.sage)
        .sensoryFeedback(.selection, trigger: selectedTab)
    }
}
