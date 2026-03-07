public struct ResolvedDefaults {
    public let position: ScreenPosition
    public let size: String
    public let screen: ScreenTarget
    public let duration: Double?
    public let fullscreen: Bool

    public init(
        cliPosition: ScreenPosition?, cliSize: String?,
        cliScreen: ScreenTarget?, cliDuration: Double?,
        cliFullscreen: Bool?, config: DefaultsConfig?
    ) {
        self.position = cliPosition
            ?? config?.position.flatMap { ScreenPosition(rawValue: $0) }
            ?? .topRight
        self.size = cliSize ?? config?.size ?? "10%"
        self.screen = cliScreen
            ?? config?.screen.flatMap { ScreenTarget.parse($0) }
            ?? .main
        self.duration = cliDuration ?? config?.duration
        self.fullscreen = cliFullscreen ?? config?.fullscreen ?? false
    }
}
