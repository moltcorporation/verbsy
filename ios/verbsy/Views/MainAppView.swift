import SwiftUI

struct MainAppView: View {
    @Binding var selectedTab: Int
    @Binding var showPaywall: Bool

    @State private var profileRoute: ProfileRoute?

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(
                showPaywall: $showPaywall,
                openLearn: { selectedTab = 1 },
                openProfile: { route in
                    profileRoute = route
                    selectedTab = 2
                }
            )
            .tabItem { Label("Home", systemImage: "house.fill") }
            .tag(0)

            LearnView()
                .tabItem { Label("Learn", systemImage: "sparkles") }
                .tag(1)

            ProfileView(showPaywall: $showPaywall, route: $profileRoute)
                .tabItem { Label("You", systemImage: "person.crop.circle") }
                .tag(2)
        }
        .tint(VerbsyDesign.sage)
    }
}
