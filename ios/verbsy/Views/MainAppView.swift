import SwiftUI

struct MainAppView: View {
    @Binding var selectedTab: Int
    @Binding var showPaywall: Bool

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(showPaywall: $showPaywall, openLearn: { selectedTab = 1 })
                .tabItem { Label("Home", systemImage: "house.fill") }
                .tag(0)

            LearnView()
                .tabItem { Label("Learn", systemImage: "sparkles") }
                .tag(1)

            ProfileView(showPaywall: $showPaywall)
                .tabItem { Label("You", systemImage: "person.crop.circle") }
                .tag(2)
        }
        .tint(VerbsyDesign.sage)
        .sensoryFeedback(.selection, trigger: selectedTab)
    }
}
